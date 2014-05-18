Loot-o-matic addon for Elder Scrolls Online
===========================================

Loot-o-matic is an addon for Elder Scrolls online that helps you manage the
loot that you obtain throughout your journey.

# Features

- Auto mark Trash items as junk
- Auto sell junk items when opening a vendor store
- Filters that allow you to mark items as junk

# Manual Install

@TODO

# Usage

Currently this script is console based and can only be used in a chat window.

Commands:

    /lootomatic filters list
    /lootomatic filters show <index>
    /lootomatic filters clear
    /lootomatic filters add <filters>
    /lootomatic filters update <index> <filters>
    /lootomatic filters delete <index>

## filters list

This command will list all of your current loot filters

## filters show

Shows more detail about a filter

## filters clear

Clear all loot filters

## filters add

Add a new loot filter

## filters update

Replaces filters

## filters delete

Deletes on of the loot filters, you can see the index by running
the `filters list` command

## Examples

@TODO

## Filter Types

@TODO

# Support

If you are having trouble with this addon, please submit a support request
on the ESOUI website.

* http://www.esoui.com/portal.php?id=114&a=listbugs

# Feature Requests

If you are wanting to have a feature adding to this addon, please submit
the feature request on the ESOUI website.

* http://www.esoui.com/portal.php?id=114&a=listfeatures

# Development

This addon follows Semantic Versioning and it also follows the gitflow
work flow of development. If either of those sound new to you, please read
the following articles:

* http://semver.org
* http://nvie.com/posts/a-successful-git-branching-model

# Contribute

https://github.com/JoshuaEstes/eso-lootomatic

# Packaging

To package this addon for distribution the following command needs to be ran:

    git archive --format=zip --prefix=Lootomatic/ HEAD > Lootomatic.zip

This will create a new zip file in the current directory ready to be uploaded
to an addon site.

# License

Copyright (C) 2014 Joshua Estes <Joshua@Estes.in>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
