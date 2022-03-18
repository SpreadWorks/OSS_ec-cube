#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
cd ${BASE_DIR}

items='
composer.json
composer.lock
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
    tmp_item=$(echo $item | sed -e 's/\//\\\//g')
	# ディレクトリ、ファイルの削除
	if ! grep -q $item .gitignore; then
	if [ ! -h $item ]; then
		if [ -d $item ]; then
			git rm -r .$item
		elif [ -f $item ]; then
			git rm $item
		fi
	fi
	fi
	# .gitignore 削除、追加
    sed -e '/'$tmp_item'/d' -i .gitignore
    echo $item >> .gitignore
done



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

# プロジェクトフォルダで利用するために__DIR__で定義されているパスを修正
# replace_file_name_array='
# index.php
# bin/console
# bin/phpunit
# bin/template_jp.php
# src/Eccube/Kernel.php
# src/Eccube/Command/GenerateProxyCommand.php
# src/Eccube/Controller/Install/InstallController.php
# src/Eccube/DependencyInjection/Compiler/PurchaseFlowPass.php
# src/Eccube/Doctrine/ORM/Mapping/Driver/AnnotationDriver.php
# src/Eccube/Doctrine/ORM/Mapping/Driver/ReloadSafeAnnotationDriver.php
# src/Eccube/Plugin/AbstractPluginManager.php
# '
# # src/Eccube/Command/LoadDataFixturesEccubeCommand.php

# for replace_file_name in ${replace_file_name_array}; do
# 	grep -q "# 置換済み" $replace_file_name; [ $? -eq 1 ] && sed -i -e "s#__DIR__.'/#__DIR__.'/../#g" $replace_file_name && echo '# 置換済み' >> $replace_file_name
# done