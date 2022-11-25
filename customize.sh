#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
cd ${BASE_DIR}

items='
/composer.json
/composer.lock
/symfony.lock
/app/Customize
/app/DoctrineMigrations
/app/Plugin
/app/PluginData
/app/template
/html/.htaccess
/html/plugin
/html/upload
/html/user_data
';

for item in $items; do
	echo "Start : "$item
    tmp_item=$(echo $item | sed -e 's/\//\\\//g')
	# ディレクトリ、ファイルの削除

	if ! grep -q $item .gitignore; then
		if [ -h .$item ]; then
			echo "Skip symlink"
		elif [ -d .$item ]; then
			git rm -r .$item
			echo "git rm -r ."$item
		elif [ -f .$item ]; then
			git rm .$item
			echo "git rm ."$item
		else
			echo "Skip unknown"
		fi
	else
		echo "Skip registed .gitignore"
	fi
	# .gitignore 削除、追加
    sed -e '/'$tmp_item'/d' -i .gitignore
    echo $item >> .gitignore
	echo "end"
done

# HTMLメールテンプレートの削除
ignore=/src/Eccube/Resource/template/default/Mail/\*.html.twig;
git rm --cached --ignore-unmatch .$ignore
echo "git rm --ignore-unmatch ."$ignore
tmp=$(echo $ignore | sed -e 's/\//\\\//g')
sed -e '/'$tmp'/d' -i .gitignore
echo $ignore >> .gitignore

# html ディレクトリをドキュメントルートにする
if grep -q '/html/' app/config/eccube/packages/framework.yaml; then
	sed -i -e "s#'/html/#'/#g" app/config/eccube/packages/framework.yaml
fi

# ログ設定を変更
if grep -q 'max_files: 60' app/config/eccube/packages/prod/monolog.yml; then
	sed -i -e "s/max_files: 60/max_files: 7/g" app/config/eccube/packages/prod/monolog.yml
fi

# index.php の追加
if [ ! -f html/index.php ]; then
	echo '<?php require_once "../index.php";' > html/index.php
fi
