# eGET - a ComputerCraft PackageManager

Not ready for production except if you already know your way around.

To install simply do 
`wget run https://raw.githubusercontent.com/sayore/cctweakedscripts/master/eget.lua`

Then you can use

eget install [appname]
eget run [appname]
eget live [appname]

## Using your own Repo

To use your own Repo change the repoURL, we do not have as of yet a .env or an equivalent, but should probably be added asap.

## Live Reload

Works by simply using

`eget live [appname] [-fa]`

-fa will Pull updates for eget too if the LiveLoading fails, so it's more of a development Flag for the liveloading, and generell debugging as it forces an eget update 100%.

## PR / Contributing

If you want to add something to the content of the Package Manager, keep a versions file in your directory from now on with the Build Number. Livereload takes care of that tho, so no need to permanently update the versions file.

The Files in their respective packages will later be added to a larger JSON that the Clients can download to check if something is not up to date.