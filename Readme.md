##  Docker Compose Updater

*Shell script to update and backup Docker Compose stacks seamlessly with a single command.* 

Change the `update.json` file to match your compose stack and update requirements and after that simply execute `docker_update.sh`

    $ ./docker_update.sh
    [INFO] Backing up directory (data)
    [SKIP] Nothing to do
    [INFO] Download & recreate test_service
    Pulling test_service ... done
    caddy is up-to-date
    [INFO] Download & recreate foo_service
    Pulling foo_service ... done
    hello is up-to-date
    [INFO] Remove old images
    [INFO] Skipping