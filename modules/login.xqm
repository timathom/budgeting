xquery version "3.1";

module namespace budget = "budget";

declare variable $budget:NONCE := xs:hexBinary(hash:md5(random:uuid()));

declare
  %rest:path("/genid")
  %rest:HEAD
  %rest:GET
  %updating
function budget:genid() {
  let $db := db:open("nonce")
  return (
    insert node <nonce loggedin="{if ($db//nonce[last()]/@loggedin eq 'true') then 'true' else 'false'}">{$budget:NONCE}</nonce> as last into $db/data
  )
};

declare
  %rest:path("/auth-one")
  %rest:HEAD
  %rest:GET
function budget:auth-one()
  as item() {
  <response>{db:open("nonce")//nonce[last()] => lower-case()}</response>
};

declare
  %rest:path("/auth-two")
  %rest:HEAD
  %rest:GET
  %rest:header-param("Authorization", "{$auth}")
  %updating
function budget:auth-two(
  $auth as item()
) {
  let $auth2 := substring-after($auth, "Digest ")
  let $user := doc("../../../data/users.xml")//hash[lower-case(
    xs:string(
      xs:hexBinary(
        hash:md5(
          concat(., lower-case(
            xs:string(
              xs:hexBinary(
                hash:md5(
                    lower-case(db:open("nonce")//nonce[last()])
                  )
                )
              )
            )
          )
        )
      )
    )
  ) = $auth2]
  return
    if ($user)
    then (replace value of node db:open("nonce")//nonce[last()]/@loggedin with "true", db:output(<response loggedin="true"/>))
    else db:output(<response loggedin="false">Unable to log in.</response>)
};

declare
  %rest:path("/logout")
  %rest:HEAD
  %rest:GET
  %updating
function budget:logout() {
  replace value of node db:open("nonce")//nonce[last()]/@loggedin with "false", db:output(<response loggedin="false"/>)
};


