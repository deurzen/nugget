# nugget
An intuitive CLI note taking and message databasing solution.

## Installation
To install the script, run the provided shell script.

```
git clone https://github.com/deurzen/nugget.git
cd nugget
bash ./installation.sh
```

Alternatively, the nugget storage directory can be added manually.

```
mkdir -p /var/lib/vimsg/nugget
chown -R $USER /var/lib/vimsg
chmod +x ./nugget.pl
mv ./nugget.pl /usr/bin/nugget
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
An existing nugget can be edited with the editor stored in the $EDITOR
environment variable; if this variable isn't defined, it defaults to Vi.

<pre>
nugget edit <i>name</i>
</pre>

#### List
With the list command, all existing nuggets are listed. This command takes an
optional argument that serves as a search string.

<pre>
nugget list [search]
</pre>

#### Remove
An existing nugget is removed from the database with the remove command.
Before removing the nugget, a conformation prompt is spawned. To force the
deletion without confirmation, use the force keyword in front of the command.

<pre>
nugget [force] remove <i>name</i>
</pre>

#### Exec
The exec command provides a way to automatically execute the commands listed
in the sequence section of a nugget, from top to bottom.

<pre>
nugget exec <i>name</i>
</pre>

#### Copy
To quickly copy a nugget, use the copy command. This command takes two
arguments, the first one being the name of the nugget you want to move, the
second being the name of the new nugget.

<pre>
nugget copy <i>source</i> <i>destination</i>
</pre>
