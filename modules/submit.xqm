xquery version "3.1";

module namespace submit = "submit";


declare
function submit:save-to-db(
$data as item()*
) {
  let $status := db:open("nonce")//nonce[last()]
  return
    if ($status/@loggedin)
    then
      (
      copy $d := $data
        modify (
        (:replace node $d/*/groceries/@active
          with attribute {"id"} {$status/lower-case(.)},:)
          if (not($d/*/groceries/@date) and not($d/*/groceries/@key))
          then (
            insert node attribute {"date"} {current-dateTime()} into $d/*/groceries,
            insert node attribute {"key"} {format-dateTime(current-dateTime(), "[h]:[m01][Pn] on [FNn], [D] [MNn] [Y]")} into $d/*/groceries
          )
          else()
        )
        return $d/*/groceries
      )
    else
      <status
        saved="false"
        submit="false"/>
};

declare
%rest:path("/main/{$func}/{$param}")
%rest:GET
%rest:POST("{$data}")
%private
%updating
function submit:main(
$func as xs:anyAtomicType,
$param as xs:anyAtomicType,
$data as item()*
) {
  switch($func)
    case "save-to-db" return  
      let $d := submit:save-to-db($data)
      return
        (
        insert node $d
          as last into db:open("groceries")/data,
        db:output($d)
        )
    case "load-from-db" return      
      db:output(web:redirect("/load-from-db", map {"list": $param}))
    default return ()
};

declare
%rest:path("/load-from-db")
%rest:query-param("list", "{$list}")
%rest:GET
%private
function submit:load-from-db(
  $list as xs:anyAtomicType
) as item()* {
  db:open("groceries")//groceries[@key = $list]
};

declare
%rest:path("/load-lists-from-db")
%private
function submit:load-lists-from-db(
) as item()* {
  <lists>{
    for $list in db:open("groceries")//groceries/@key/data()
    return <list>{$list}</list>
  }</lists>
};

declare
%rest:path("/parse")
%rest:POST("{$data}")
function submit:parse(
  $data as item()*
) as item()* {
  <innerHTML>{html:parse($data)/html/body/div[@id = "subform"]}</innerHTML>
};