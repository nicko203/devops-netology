package main

import "fmt"

func main() {

    var nUpperLimit int = 100
    var nDivider int = 3
    
    for nCount := 1; nCount <= nUpperLimit; nCount++{
	if nCount%nDivider == 0{
	    fmt.Println(nCount)

	}
    }

}
