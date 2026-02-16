package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"time"
)

type rpcRequest struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      json.RawMessage `json:"id,omitempty"`
	Method  string          `json:"method"`
	Params  json.RawMessage `json:"params,omitempty"`
}

type rpcResponse struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      json.RawMessage `json:"id,omitempty"`
	Result  any             `json:"result,omitempty"`
	Error   *rpcError       `json:"error,omitempty"`
}

type rpcError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

type mcpTool struct {
	Name        string         `json:"name"`
	Description string         `json:"description"`
	InputSchema map[string]any `json:"inputSchema"`
}

type toolsListResult struct {
	Tools []mcpTool `json:"tools"`
}

type toolsCallParams struct {
	Name      string         `json:"name"`
	Arguments map[string]any `json:"arguments"`
}

type toolsCallResult struct {
	Content []toolContent `json:"content"`
	IsError bool          `json:"isError,omitempty"`
}

type toolContent struct {
	Type string `json:"type"`
	Text string `json:"text"`
}

type initializeResult struct {
	ProtocolVersion string         `json:"protocolVersion"`
	ServerInfo      map[string]any `json:"serverInfo"`
	Capabilities    map[string]any `json:"capabilities"`
}

func main() {
	var debug bool
	flag.BoolVar(&debug, "debug", false, "enable debug logging to stderr")
	flag.Parse()

	ctx := context.Background()
	server := &mcpServer{
		in:    bufio.NewReader(os.Stdin),
		out:   bufio.NewWriter(os.Stdout),
		debug: debug,
	}

	if err := server.serve(ctx); err != nil {
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(1)
	}
}

type mcpServer struct {
	in    *bufio.Reader
	out   *bufio.Writer
	debug bool
}

func (s *mcpServer) serve(ctx context.Context) error {
	for {
		msg, err := readFramedMessage(s.in)
		if err != nil {
			if errors.Is(err, io.EOF) {
				return nil
			}
			return err
		}
		if len(bytes.TrimSpace(msg)) == 0 {
			continue
		}

		var req rpcRequest
		if err := json.Unmarshal(msg, &req); err != nil {
			// If we can't parse, we can't respond reliably.
			if s.debug {
				fmt.Fprintf(os.Stderr, "failed to unmarshal request: %v\n", err)
			}
			continue
		}

		// Notifications have no id; do not respond.
		isNotification := len(bytes.TrimSpace(req.ID)) == 0
		if s.debug {
			fmt.Fprintf(os.Stderr, "<- %s\n", strings.TrimSpace(string(msg)))
		}

		if isNotification {
			// best-effort: ignore.
			continue
		}

		resp := s.handle(ctx, &req)
		if err := writeFramedMessage(s.out, resp); err != nil {
			return err
		}
	}
}

func (s *mcpServer) handle(ctx context.Context, req *rpcRequest) rpcResponse {
	switch req.Method {
	case "initialize":
		return rpcResponse{
			JSONRPC: "2.0",
			ID:      req.ID,
			Result: initializeResult{
				ProtocolVersion: "2024-11-05",
				ServerInfo: map[string]any{
					"name":    "mymcp",
					"version": "0.1.0",
				},
				Capabilities: map[string]any{
					"tools": map[string]any{},
				},
			},
		}
	case "tools/list":
		return rpcResponse{
			JSONRPC: "2.0",
			ID:      req.ID,
			Result:  toolsListResult{Tools: []mcpTool{toolCreatePRFromDefault()}},
		}
	case "tools/call":
		var p toolsCallParams
		if err := json.Unmarshal(req.Params, &p); err != nil {
			return rpcResponse{JSONRPC: "2.0", ID: req.ID, Error: &rpcError{Code: -32602, Message: "invalid params"}}
		}
		switch p.Name {
		case toolCreatePRFromDefault().Name:
			text, err := runCreatePRFromDefault(ctx, p.Arguments)
			if err != nil {
				return rpcResponse{
					JSONRPC: "2.0",
					ID:      req.ID,
					Result:  toolsCallResult{Content: []toolContent{{Type: "text", Text: err.Error()}}, IsError: true},
				}
			}
			return rpcResponse{JSONRPC: "2.0", ID: req.ID, Result: toolsCallResult{Content: []toolContent{{Type: "text", Text: text}}}}
		default:
			return rpcResponse{JSONRPC: "2.0", ID: req.ID, Error: &rpcError{Code: -32601, Message: "tool not found"}}
		}
	default:
		return rpcResponse{JSONRPC: "2.0", ID: req.ID, Error: &rpcError{Code: -32601, Message: "method not found"}}
	}
}

func toolCreatePRFromDefault() mcpTool {
	return mcpTool{
		Name:        "git_create_pr_from_default",
		Description: "Create a GitHub PR using gh based on commits ahead of the repo default branch.",
		InputSchema: map[string]any{
			"type": "object",
			"properties": map[string]any{
				"repoPath": map[string]any{
					"type":        "string",
					"description": "Path to the git repository. Defaults to current working directory.",
				},
				"base": map[string]any{
					"type":        "string",
					"description": "Base branch name. Defaults to the repository default branch.",
				},
				"head": map[string]any{
					"type":        "string",
					"description": "Head branch name. Defaults to current branch.",
				},
				"title": map[string]any{
					"type":        "string",
					"description": "PR title. Defaults to HEAD commit subject.",
				},
				"body": map[string]any{
					"type":        "string",
					"description": "PR body. Defaults to a bullet list of commits ahead of base.",
				},
				"draft": map[string]any{
					"type":        "boolean",
					"description": "Create as draft PR.",
					"default":     false,
				},
				"push": map[string]any{
					"type":        "boolean",
					"description": "git push -u origin HEAD before creating the PR.",
					"default":     true,
				},
			},
			"additionalProperties": false,
		},
	}
}

type createPRArgs struct {
	RepoPath string
	Base     string
	Head     string
	Title    string
	Body     string
	Draft    bool
	Push     bool
}

func runCreatePRFromDefault(ctx context.Context, raw map[string]any) (string, error) {
	args := createPRArgs{Push: true}
	if v, ok := raw["repoPath"].(string); ok {
		args.RepoPath = v
	}
	if v, ok := raw["base"].(string); ok {
		args.Base = v
	}
	if v, ok := raw["head"].(string); ok {
		args.Head = v
	}
	if v, ok := raw["title"].(string); ok {
		args.Title = v
	}
	if v, ok := raw["body"].(string); ok {
		args.Body = v
	}
	if v, ok := raw["draft"].(bool); ok {
		args.Draft = v
	}
	if v, ok := raw["push"].(bool); ok {
		args.Push = v
	}

	repoDir := strings.TrimSpace(args.RepoPath)
	if repoDir == "" {
		wd, err := os.Getwd()
		if err != nil {
			return "", err
		}
		repoDir = wd
	}

	ctx, cancel := context.WithTimeout(ctx, 2*time.Minute)
	defer cancel()

	if _, err := mustOK(ctx, repoDir, "git", "rev-parse", "--is-inside-work-tree"); err != nil {
		return "", fmt.Errorf("not a git repository: %w", err)
	}
	if _, err := mustOK(ctx, repoDir, "gh", "--version"); err != nil {
		return "", fmt.Errorf("gh is required: %w", err)
	}

	base := strings.TrimSpace(args.Base)
	if base == "" {
		b, _ := detectDefaultBranch(ctx, repoDir)
		base = b
	}
	if base == "" {
		base = "master"
	}

	head := strings.TrimSpace(args.Head)
	if head == "" {
		out, err := mustOK(ctx, repoDir, "git", "branch", "--show-current")
		if err != nil {
			return "", err
		}
		head = strings.TrimSpace(out)
		if head == "" {
			return "", errors.New("detached HEAD: please specify 'head'")
		}
	}

	if _, err := mustOK(ctx, repoDir, "git", "fetch", "--prune", "origin"); err != nil {
		return "", err
	}

	baseRef := "origin/" + base
	if _, err := mustOK(ctx, repoDir, "git", "show-ref", "--verify", "--quiet", "refs/remotes/"+baseRef); err != nil {
		// Try fetching the base specifically in case it isn't present.
		_, _ = mustOK(ctx, repoDir, "git", "fetch", "origin", base)
	}

	commitLines, err := mustOK(ctx, repoDir, "git", "log", "--pretty=format:%h\t%s", baseRef+"..HEAD")
	if err != nil {
		return "", err
	}
	commitLines = strings.TrimSpace(commitLines)
	if commitLines == "" {
		return "", fmt.Errorf("no commits ahead of %s", baseRef)
	}

	if args.Title == "" {
		title, _ := mustOK(ctx, repoDir, "git", "log", "-1", "--pretty=%s", "HEAD")
		args.Title = strings.TrimSpace(title)
		if args.Title == "" {
			args.Title = fmt.Sprintf("%s -> %s", base, head)
		}
	}

	if args.Body == "" {
		var b strings.Builder
		b.WriteString("Commits in this PR:\n\n")
		for _, line := range strings.Split(commitLines, "\n") {
			line = strings.TrimSpace(line)
			if line == "" {
				continue
			}
			parts := strings.SplitN(line, "\t", 2)
			sha := parts[0]
			subject := ""
			if len(parts) == 2 {
				subject = parts[1]
			}
			b.WriteString("- ")
			b.WriteString(sha)
			if subject != "" {
				b.WriteString(" ")
				b.WriteString(subject)
			}
			b.WriteString("\n")
		}
		args.Body = strings.TrimSpace(b.String())
	}

	if args.Push {
		if _, err := mustOK(ctx, repoDir, "git", "push", "-u", "origin", "HEAD"); err != nil {
			return "", err
		}
	}

	ghArgs := []string{"pr", "create", "--base", base, "--head", head, "--title", args.Title, "--body", args.Body}
	if args.Draft {
		ghArgs = append(ghArgs, "--draft")
	}

	out, err := mustOK(ctx, repoDir, "gh", ghArgs...)
	if err != nil {
		return "", err
	}
	out = strings.TrimSpace(out)
	if out == "" {
		out = "PR created."
	}
	return out, nil
}

func detectDefaultBranch(ctx context.Context, dir string) (string, error) {
	// Preferred: gh knows the actual default branch.
	if out, err := mustOK(ctx, dir, "gh", "repo", "view", "--json", "defaultBranchRef", "--jq", ".defaultBranchRef.name"); err == nil {
		out = strings.TrimSpace(out)
		if out != "" {
			return out, nil
		}
	}

	// Fallback 1: origin/HEAD symbolic ref.
	if out, err := mustOK(ctx, dir, "git", "symbolic-ref", "refs/remotes/origin/HEAD"); err == nil {
		out = strings.TrimSpace(out)
		// refs/remotes/origin/main
		if strings.HasPrefix(out, "refs/remotes/origin/") {
			return strings.TrimPrefix(out, "refs/remotes/origin/"), nil
		}
	}

	// Fallback 2: parse `git remote show origin`.
	if out, err := mustOK(ctx, dir, "git", "remote", "show", "origin"); err == nil {
		re := regexp.MustCompile(`(?m)^\s*HEAD branch:\s*(\S+)\s*$`)
		m := re.FindStringSubmatch(out)
		if len(m) == 2 {
			return strings.TrimSpace(m[1]), nil
		}
	}

	return "", errors.New("could not detect default branch")
}

func mustOK(ctx context.Context, dir string, name string, args ...string) (string, error) {
	cmd := exec.CommandContext(ctx, name, args...)
	cmd.Dir = dir
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	if err := cmd.Run(); err != nil {
		msg := strings.TrimSpace(stderr.String())
		if msg == "" {
			msg = err.Error()
		}
		return "", fmt.Errorf("%s %s failed: %s", name, strings.Join(args, " "), msg)
	}
	return stdout.String(), nil
}

func readFramedMessage(r *bufio.Reader) ([]byte, error) {
	// MCP usually uses LSP-style framing: Content-Length: N\r\n\r\n<json>
	// Be tolerant: if stream starts with '{', treat as a single-line JSON message.
	first, err := r.Peek(1)
	if err != nil {
		return nil, err
	}
	if first[0] == '{' {
		line, err := r.ReadBytes('\n')
		if err != nil {
			if errors.Is(err, io.EOF) {
				return bytes.TrimSpace(line), io.EOF
			}
			return nil, err
		}
		return bytes.TrimSpace(line), nil
	}

	contentLength := -1
	for {
		line, err := r.ReadString('\n')
		if err != nil {
			return nil, err
		}
		line = strings.TrimRight(line, "\r\n")
		if line == "" {
			break
		}
		if strings.HasPrefix(strings.ToLower(line), "content-length:") {
			v := strings.TrimSpace(line[len("content-length:"):])
			n, err := strconv.Atoi(v)
			if err != nil {
				return nil, fmt.Errorf("invalid Content-Length: %q", v)
			}
			contentLength = n
		}
	}
	if contentLength < 0 {
		return nil, errors.New("missing Content-Length header")
	}

	buf := make([]byte, contentLength)
	_, err = io.ReadFull(r, buf)
	return buf, err
}

func writeFramedMessage(w *bufio.Writer, resp rpcResponse) error {
	b, err := json.Marshal(resp)
	if err != nil {
		return err
	}

	header := fmt.Sprintf("Content-Length: %d\r\n\r\n", len(b))
	if _, err := w.WriteString(header); err != nil {
		return err
	}
	if _, err := w.Write(b); err != nil {
		return err
	}
	if err := w.Flush(); err != nil {
		return err
	}
	return nil
}
