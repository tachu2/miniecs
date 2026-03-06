package main

import (
	"encoding/json"
	"log"
	"net"
	"net/http"
	"os"
)

type Response struct {
	Message   string `json:"message"`
	Hostname  string `json:"hostname"`
	ServerIP  string `json:"server_ip"`
}

// getServerIP はこのコンテナ（サーバー）のIPアドレスを返す
func getServerIP() string {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return ""
	}
	for _, addr := range addrs {
		if ipnet, ok := addr.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ipnet.IP.To4() != nil {
				return ipnet.IP.String()
			}
		}
	}
	return ""
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		hostname, _ := os.Hostname()
		w.Header().Set("Content-Type", "application/json")
		response := Response{
			Message:  "Hello World",
			Hostname: hostname,
			ServerIP: getServerIP(),
		}
		json.NewEncoder(w).Encode(response)
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})

	log.Println("Server starting on port 8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}