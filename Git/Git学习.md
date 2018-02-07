# Git 初识版本控制工具
>此笔记是抄书(《Android第一行代码》)上面的,很实用,记录下来

[TOC]

# 1. 建议使用命令行,所有系统都是通用的.

# 2. 配置身份:

  - `git config --global user.name "xfhy"`
  - `git config --global user.email "131344644@qq.com"`

# 3. 创建代码仓库

- 用`cd`命令打开目录,到项目的目录下,输入命令`git init`,即可创建代码仓库.
- 创建仓库后,会在项目目录下创建一个 **.git** 的文件夹,该文件夹是用来记录本地所有的`Git`
操作的,可以通过`ls-al`查看所有文件和文件夹

# 4. 删除本地代码仓库

- 删除那个文件夹(.git)就行  rm -r .git

# 5. 提交本地代码:

  - git add AndroidManifest.xml   :添加Android..文件
  - git add src :添加src文件夹
  - git add .   :添加所有的文件
  - git commit -m "First commit" :提交刚刚添加的文件,必须要有-m 和后面的描述
  - git log :查看提交记录
 
# Git 版本工具进阶

# 6. 忽略文件

  - 在根目录下,新建一个`.gitignore`的文件
  - 用`vi`编辑它,里面的内容就是需要忽略
的文件或者文件夹,一个文件夹写一行.
  - 这样,在提交的时候不会提交`.gitignore`里面的文件
或者文件夹.
  - 我们并不需要自己去创建.gitignore文件,Android Studio在创建项目的时候会自动bang我们创建出.gitignore文件,一个在根目录下面,一个在app模块下面.
  - 比如说,app模块下面的所有测试文件都只是给我自己使用的,我并不想它们添加到版本控制中,那么就可以这样修改app/.gitignore文件中的内容:

		/build
		/src/test
		/src/androidTest

# 7. 查看修改内容  

  - 只需要使用`status`命令就可以了.在项目根目录下输入:`git status`即可.
  - 输入:`git diff`还可以查看所有文件的更改内容(-号代表删除的部分,+号代表增加的部分).
  - 如果只想看某个文件的更改内容,则使用:`git diff` 目录(项目下的目录)+文件名


# 8. 撤销未提交的修改

  - 加入我们修改了MainActivity里的代码,现在如果想撤销这个修改就可
以使用checkout命令,用法如下:<br/>

	`git checkout src/com/example/providertest/MainActivity.java`

**注意:这种撤销方式只适用于那些还没有执行过`add`命令的文件.如果已经添加,则先取消添加
,然后才可以撤销提交,取消添加使用的是`reset`命令.用法如下所示:
`git reset HEAD src/com/example/providertest/MainActivity.java`**

# 9. 查看提交记录
  - 可以使用log命令查看历史提交记录,用法如下:`git log`


# Git 版本控制工具的高级用法

# 10.分支
  - 在现有代码上开辟一个分支口,使得代码可以在主干线和分支线上同时进行开发,且相互之间不影响.
  - git branch -a : 查看当前的版本库中有哪些分支.
  - git branch version1.0 : 创建一个分支,名字为version1.0
  - git checkout version1.0 : 切换到version1.0这个分支上
  
  - 把在version1.0分支上修改并提交的内容合并到master分支上:
    * 第一步:git checkout master
    * 第二步:git merge version1.0
  
  - 删除分支:git branch -D version1.0


# 11. 与远程版本库协作:

  * 比如说现在有一个远程版本库的`Git`地址是`https:github.com/exmaple/test.git`

    就可以使用如下命令将远程代码下载到本地:
   `git clone https://github.com/exmaple/test.git`
  
  * 将本地的代码修改和提交到远程版本库:
   `git push origin master`(需要借助`push`命令,其中`origin`部分指定的是远程版本库的
   `Git地址`,`master`部分指定的是同步到哪一个分支上)
  
  * 将远程版本库上的修改同步到本地:

    Git提供了两种命令来完成此功能,分别是 **fetch** 和 **pull**
     
    - fetch的语法规则和push是差不多的,如下所示:
     `git fetch origin master` : 将远程版本库上的修改同步到本地,不过同步下来的代码
     并不会合并到任何分支上去,而是会存放到一个`origin/master`分支上,这时我们可以
     通过`diff`命令来查看远程版本库到底修改了哪些东西:
        `git diff origin/master`
     之后再调用`merge`命令将`origin/master`分支上的修改合并到主分支即可,如下所示:
        `git merge origin/master`
     
    - `pull`命令则是相当于将`fetch`和`merge`这两个命令放在一起执行了,它可以从远程版本库
     上获取最新的代码并且合并到本地,用法如下:
        `git pull origin master `

## 12.删除错误提交的commit

方法:
1.先git log查看最近一次正确的commit_id(git reflog查看命令历史)
2.输入一下命令

	git reset --hard <commit_id>
    git push origin HEAD --force

 git reset –-hard：彻底回退到某个版本，本地的源码也会变为上一个版本的内容.

HEAD 最近一个提交

HEAD^ 上一次

上一个版本就是HEAD^，上上一个版本就是HEAD^^，当然往上100个版本写100个^比较容易数不过来，所以写成HEAD~100。

<commit_id>  每次commit的SHA1值. 可以用git log 看到,也可以在页面上commit标签页里找到.

## 13. 追加修改

当开发者提交了一个commit之后,如果发现该commit有错,可以随时对这个commit进行修改,例如在文件中笔者第一次修改,增加了一行文本"test1"并通过add,commit操作进行了提交.这时候笔者想修改这行文本为"test1/2",这时候就不用重新生成一个提交,直接使用`git commit --amend`指令即可,完整的示例如下所示.
```
git add README.md
git commit -m "test1"
subl README.md     (修改文件)
git add README.md
git commit --amend -m "add test2"
```
通过这种方式可以修改commit,而不是通过新的commit来修正前一个错误的commit.















