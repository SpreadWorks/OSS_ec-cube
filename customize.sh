#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
cd ${BASE_DIR}

# .gitignore の最終行にcomposer関連のファイルを追加
if ! grep -q 'composer.json' .gitignore; then
	echo 'composer.json' >> .gitignore
fi

if ! grep -q 'composer.lock' .gitignore; then
	echo 'composer.lock' >> .gitignore
fi

if ! grep -q 'app/Customize' .gitignore; then
	echo 'app/Customize' >> .gitignore
fi

# composer関連のファイルを削除
git rm composer.json
git rm composer.lock


# 不要なファイルを削除
git rm -r app/Customize
git rm -r app/DoctrineMigrations
git rm -r app/Plugin/AnnotatedRouting
git rm -r app/Plugin/EntityExtension
git rm -r app/Plugin/EntityForm
git rm -r app/Plugin/FormExtension
git rm -r app/Plugin/HogePlugin
git rm -r app/Plugin/MigrationSample
git rm -r app/Plugin/PurchaseProcessors
git rm -r app/Plugin/QueryCustomize
git rm -r html/upload
git rm -r html/user_data


# html ディレクトリをドキュメントルートにする
if grep -q '/html/' app/config/eccube/packages/framework.yaml; then
	sed -i -e "s#'/html/#'/#g" app/config/eccube/packages/framework.yaml
fi

# ログ設定を変更
if grep -q 'max_files: 60' app/config/eccube/packages/prod/monolog.yml; then
	sed -i -e "s/max_files: 60/max_files: 7/g" app/config/eccube/packages/prod/monolog.yml
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