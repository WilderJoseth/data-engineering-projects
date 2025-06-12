from scripts import ingest_arrival

def main():
    print("\n------------------ START PIPELINE PROCESS ------------------")
    ingest_arrival.main()
    print("\n------------------ END PIPELINE PROCESS ------------------")

if __name__ == "__main__":
    main()