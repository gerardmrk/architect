package main

import (
	"flag"
	"fmt"
	"os"
)

type Flag struct {
	Name string
	Type string
	Opts []string
	Dflt interface{}
}

var commands = map[string][]Flag{
	"init": []Flag{},
	"validate": []Flag{
		Flag{"all", "Bool", nil, false},
	},
	"format": []Flag{},
}

func main() {
	// check if the command is valid
	cmd, ok := commands[os.Args[1]]
	if !ok {
		fmt.Println("invalid command")
		return
	}

	for _, fl := range cmd {
		fmt.Println(fl)
	}

	// opt := flag.Bool("all", false, "validate all blueprints")

	flag.Parse()
	fmt.Println(flag.Args())
}

func ValidateAllBlueprints() {

}
