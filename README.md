# Nugget
A simple and intuitive CLI note taking and message databasing application.

## What is a nugget?
Historically, a nugget is a small lump of gold or other precious metal found
ready-formed in the earth.

In this context, a nugget has the same connotation. A nugget is a vital or
valuable piece of information that you want to store for future reference.
A nugget has the following properties:

- **Title**: The name or description of the nugget.
- **URI**: A reference to or identifier for the content of the nugget, such as
           a link.
- **Body**: The main content of the nugget.
- **Sequence**: A sequence of commands associated with the content of the
                nugget. This sequence can be executed with the _exec_ command.


## Installation
To install the script, run the provided shell script.

```
git clone https://github.com/deurzen/nugget.git
cd nugget
./install.sh
```

Alternatively, the nugget storage directory can be added manually. This
directory can be altered through the `VIMSG_DIR` variable in the perl script.

```
mkdir -p /var/lib/vimsg/{nugget,deleted}
chown -R $USER /var/lib/vimsg
pp -o nugget nugget.pl
install nugget /usr/local/bin/
```

## Usage
#### Add
To add a nugget to the database, run the following command:

<pre>
nugget add <i>name</i>
</pre>

#### Show
To print out the contents of a nugget, use the show command.

<pre>
nugget show <i>name</i>
</pre>

#### Edit
An existing nugget can be edited with the editor stored in the `EDITOR`
environment variable; if this variable isn't defined, it defaults to Vi.

<pre>
nugget edit <i>name</i>
</pre>

#### List
With the list command, all existing nuggets are listed. This command takes an
optional argument that serves as a search string.

<pre>
nugget list [<i>search</i>]
</pre>

#### Remove
An existing nugget is removed from the database with the remove command.
Before removing the nugget, a confirmation question is prompted. To force the
deletion without confirmation, use the force keyword in front of the command.

<pre>
nugget [force] remove <i>name</i>
</pre>

#### Exec
The exec command provides a way to automatically execute the commands listed
in the sequence section of a nugget. As of yet only single
line bash commands are evaluated in sequence from top to bottom. Support for
other languages will be added.

<pre>
nugget exec <i>name</i>
</pre>

#### Copy
To quickly copy a nugget, use the copy command. This command takes two
arguments, the first one being the name of the nugget you want to copy, the
second being the name of the new nugget.

<pre>
nugget copy <i>source</i> <i>destination</i>
</pre>

