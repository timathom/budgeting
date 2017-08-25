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
        replace node $d/*/groceries/@active
          with attribute {"id"} {$status/lower-case(.)}
        )
        return
          (
          <status
            saved="true"
            submit="false">{$d}</status>
          )
      )
    else
      <status
        saved="false"
        submit="false"/>
};

declare
%rest:path("/main/{$func}/{$arity}")
%rest:GET
%rest:POST("{$data}")
%private
%updating
function submit:main(
$func as xs:anyAtomicType,
$arity as xs:integer,
$data as item()*
) {
  let $d := submit:save-to-db($data)
  return
    (
    insert node $d/*/*
      as last into db:open("groceries")/data,
    db:output($d)
    )
};
