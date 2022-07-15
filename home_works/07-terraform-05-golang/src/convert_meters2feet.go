package main

import "fmt"

func main() {
    fmt.Print("Введите количество метров: ")
    var meters float64

    fmt.Scanf("%f", &meters)

    feet := meters / 0.3084

    fmt.Println(feet)    
}
