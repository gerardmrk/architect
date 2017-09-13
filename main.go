package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
)

func main() {
	var debug = new(DebugCmd)
	var format = new(FormatCmd)
	var validate = new(ValidateCmd)
	var remotestate = new(RemoteStateCmd)

	var debugCmd = flag.NewFlagSet("debug", flag.ExitOnError)
	var formatCmd = flag.NewFlagSet("format", flag.ExitOnError)
	var validateCmd = flag.NewFlagSet("validate", flag.ExitOnError)
	var remotestateCmd = flag.NewFlagSet("remotestate", flag.ExitOnError)

	debug.FlagSet = debugCmd

	format.FlagSet = formatCmd
	format.All = formatCmd.Bool("all", true, "Format all blueprints")

	validate.FlagSet = validateCmd
	validate.All = validateCmd.Bool("all", true, "Validate all blueprints")

	remotestate.FlagSet = remotestateCmd
	remotestate.AppName = remotestateCmd.String("app-name", "", "Application name")
	remotestate.ConfigPath = remotestateCmd.String("config-path", "config.tf", "Path to generate the config file")
	remotestate.StorageID = remotestateCmd.String("storage-id", "", "Unique ID of the remote state's cloud storage")
	remotestate.StorageKey = remotestateCmd.String("storage-key", "", "Key path to the state file")
	remotestate.StorageRg = remotestateCmd.String("storage-region", "", "Cloud region code where the state storage resides in")
	remotestate.LockID = remotestateCmd.String("lock-id", "", "Unique ID of the state lock service")
	remotestate.Cleanup = remotestateCmd.Bool("cleanup-local", true, "Whether to remove existing state files after porting to remote")
	remotestate.NonManual = remotestateCmd.Bool("script-invocation", false, "Whether the command was run by an automated script")

	var cmds = map[string]Opt{
		"debug":       debug,
		"validate":    validate,
		"format":      format,
		"remotestate": remotestate,
	}

	// verify that a subcommand is present
	// os.Args[0] = main cmd
	// os.Args[1] = sub cmd
	if len(os.Args) < 2 {
		fmt.Println("subcommand is required")
		os.Exit(1)
	}

	cmd, ok := cmds[os.Args[1]]

	// verify that the subcommand is valid
	if !ok {
		fmt.Println("invalid subcommand")
		os.Exit(1)
	}

	// parse all sub-arguments/flags
	cmd.Parse(os.Args[2:])
	err := cmd.Handle()

	if err != nil {
		panic(err)
	}
}

// Cmd is a registered CLI subcommand instantiated with flag.NewFlagSet
type Cmd struct {
	FlagSet *flag.FlagSet
}

// Opt implements a set of helper methods for a CLI subcommand
type Opt interface {
	Validate() error
	Handle() error
	Parse([]string)
}

// DebugCmd [TEMPORARY] temporary measure to debug code without needing to switch go workspaces
type DebugCmd struct {
	Cmd
}

// FormatCmd formats the scoped set of Terraform config files according to HCL syntax
type FormatCmd struct {
	Cmd
	All *bool
}

// ValidateCmd validates the scoped set of Terraform config files according to HCL syntax
type ValidateCmd struct {
	Cmd
	All *bool
}

// RemoteStateCmd updates the remote state backend for the 'default' Terraform workspace
type RemoteStateCmd struct {
	Cmd
	AppName    *string
	ConfigPath *string
	StorageID  *string
	StorageKey *string
	StorageRg  *string
	LockID     *string
	Cleanup    *bool
	NonManual  *bool
}

// Parse calls FlagSet.Parse on the CLI arguments for the 'debug' subcommand
func (c *DebugCmd) Parse(a []string) { c.FlagSet.Parse(a) }

// Parse calls FlagSet.Parse on the CLI arguments for the 'format' subcommand
func (c *FormatCmd) Parse(a []string) { c.FlagSet.Parse(a) }

// Parse calls FlagSet.Parse on the CLI arguments for the 'validate' subcommand
func (c *ValidateCmd) Parse(a []string) { c.FlagSet.Parse(a) }

// Parse calls FlagSet.Parse on the CLI arguments for the 'remotestate' subcommand
func (c *RemoteStateCmd) Parse(a []string) { c.FlagSet.Parse(a) }

// Validate validates all flags/arguments for the 'debug' subcommand
func (c *DebugCmd) Validate() error { return nil }

// Validate validates all flags/arguments for the 'format' subcommand
func (c *FormatCmd) Validate() error { return nil }

// Validate validates all flags/arguments for the 'validate' subcommand
func (c *ValidateCmd) Validate() error { return nil }

// Validate validates all flags/arguments for the 'remotestate' subcommand
func (c *RemoteStateCmd) Validate() error {
	return nil
}

// Handle [TEMPORARY]
func (c *DebugCmd) Handle() error {
	return nil
}

// Handle invokes 'terraform fmt' with the given scope
func (c *FormatCmd) Handle() error {
	return nil
}

// Handle invokes 'terraform validate' with the given scope
func (c *ValidateCmd) Handle() error {
	return nil
}

// Handle (re)configures the main backend with the supplied arguments
func (c *RemoteStateCmd) Handle() error {
	cfg := fmt.Sprintf(
		`# [%s] main remote state backend
terraform {
  backend "s3" {
    bucket         = "%s"
    key            = "%s"
    region         = "%s"
    dynamodb_table = "%s"
  }
}
`, *c.AppName, *c.StorageID, *c.StorageKey, *c.StorageRg, *c.LockID)

	// write the file (containing the remote state backend config for the 'default'
	// workspace) to the specified location
	err := ioutil.WriteFile(*c.ConfigPath, []byte(cfg), 0644)

	if err != nil {
		return err
	}

	// execute 'terraform init -reconfigure -force-copy' to reinitialize
	// and move the local copy to the remote state
	cmd := exec.Command("terraform", "init", "-reconfigure", "-force-copy")

	out, err := cmd.Output()

	if err != nil {
		return err
	}

	fmt.Println(string(out))

	return nil
}
