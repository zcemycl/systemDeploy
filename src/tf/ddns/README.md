## How to run?
1. Set up the infrastructure by terraform.
2. Export environment variables for python script.
    ```bash
    export APIGW_INVOKE_URI=
    export X_API_KEY=
    ```
3. Run cronjob to regularly update. `python src/local/main.py`
    ```bash
    # linux
    sudo apt update
    sudo apt install cron
    # macos -> need permission settings
    brew install cron

    # common after installation
    crontab -e
    # add this
    */2 * * * * APIGW_INVOKE_URI= X_API_KEY= python src/local/main.py >> log.txt 2>&1
    ```

### References
1. https://www.youtube.com/watch?v=yzT92pEcIvM
2. https://aws.amazon.com/blogs/startups/how-to-build-a-serverless-dynamic-dns-system-with-aws/#:~:text=AWS%20Services%20We%20Use%20in%20Our%20Dynamic%20DNS%20system&text=Your%20code%20is%20always%20ready,events%20from%20other%20AWS%20services.
3. https://www.bejarano.io/fixing-cron-jobs-in-mojave/
