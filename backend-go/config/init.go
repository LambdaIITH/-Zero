package config

func Init() {
	LoadEnv()
	ConnectPSQL()
}
