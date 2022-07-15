package main

import "fmt"

func main() {

    var nMinValue int = 0
    
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}

    nMinValue = x[0]

    for nCount := 1; nCount < len(x); nCount++{
	if nMinValue > x[nCount] {
	    nMinValue = x[nCount]
	}
    }

    fmt.Println(nMinValue)
}
