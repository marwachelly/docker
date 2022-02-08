#!/usr/bin/env bash

# read paramater
FORK=""
NAME_SHOP=""
for i in "$@"
do
case $i in

    -f=*|--fork=*)
    FORK="${i#*=}"
    shift # past argument=value
    ;;

    -n=*|--name=*)
    NAME_SHOP="${i#*=}"
    shift # past argument=value
    ;;

esac
done

if [ "$FORK" = "" ]; then
echo "unknown github repo to clone (option -f or --fork is required)"
exit
fi

if [ "$NAME_SHOP" = "" ]; then
echo "unknown shop name (option -n or --name is required)"
exit
fi
# creation du repertoire archive .composer
if [ ! -d ~/.composer ]; then
echo "creating ~/.composer archive folder"
mkdir ~/.composer
fi
#clonage du projet
git clone $FORK $(pwd)/../presta_test/$NAME_SHOP

cd $(pwd)/../presta_test/$NAME_SHOP
#composer install
echo "installing composer dependencies"
docker run --rm \
    --user $(id -u):$(id -g) \
    --volume $(pwd):/app \
    --volume ~/.composer:/tmp:rw \
    --name composer_prestashop \
    composer install --no-interaction --ignore-platform-reqs

#install boutique

echo "Debut installation de la boutique"

docker exec apache-upgrade-presta-dev php /var/www/html/$NAME_SHOP/install-dev/index_cli.php --language=en --country=fr --domain=127.0.0.1:8081 --db_server=10.1.37.2 --db_user=root --db_name=presta --db_password=sifast2016 --firstname=Demo --lastname=Prestashop --email=demo@prestashop.com --password=prestashop_demo --db_create=1

mysql --host="10.1.37.2" --user="root" --password="sifast2016" --database="presta" --execute="UPDATE ps_shop_url SET physical_uri = '/"$NAME_SHOP"/' WHERE ps_shop_url.id_shop_url = 1;"

sudo chown -R $(whoami) $(pwd)
setfacl -Rm user:$(whoami):rwx $(pwd)
setfacl -dRm user:$(whoami):rwx $(pwd)
sudo chown -R www-data $(pwd)
git checkout .

#echo "Fin de l'installation de la boutique"

