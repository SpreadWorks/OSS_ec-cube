#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
cd ${BASE_DIR}

items='
/app/Customize
/app/DoctrineMigrations
/app/Plugin
/app/PluginData
/app/template
.history
.tmp
';

for item in $items; do
	echo "Start : "$item
    tmp_item=$(echo $item | sed -e 's/\//\\\//g')
	# ディレクトリ、ファイルの削除

	if ! grep -q "^$item$" .gitignore; then
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


# Pluginが削除されていることを確認
# .gitignoreの変更を確認
# 削除ファイルの確認
