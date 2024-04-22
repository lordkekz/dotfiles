#!/usr/bin/env nu

def first-or-null (): list<any> -> any {
  $in | append [null] | first
}

def last-or-null (): list<any> -> any {
  $in | prepend [null] | last
}

def walklink (): path -> list<string> {
  mut next: string = $in;
  mut result: list<string> = [];
  while (($next != null) and ($next | path exists)) {
    $result = ($result | append $next);
    $next = (ls $next -l | get target | append null | first);
  }
  return $result;
}

def dwhich (application: string, ...rest: string) -> table<command: string, steps: list<path>> {
  $rest | prepend $application | each {|command|
    {
      command: $command,
      steps: (which -a $command | where path != "" | each {|x| $x.path | walklink })
    }
  }
}

def dwhich1 (application: string) -> path {
  dwhich $application | get steps | first-or-null | first-or-null | last-or-null
}


def find-inpermanent (): path -> table {
  sudo nu -c 'rsync -amvxx --dry-run --no-links / /this/path/does/not/exist
  | lines | skip 2 | drop 3
  | where {|x| $x !~ "^skipping|/$"}
  | each {|x| "/" + $x | $in}
  | to nuon' | from nuon
}

