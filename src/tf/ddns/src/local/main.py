import requests

if __name__ == "__main__":
    ip = requests.get("http://checkip.amazonaws.com/").content.decode('utf8')
    print(ip.strip())
