
    <!doctype html>
    <html>

    <head>
        <meta charset="utf-8">
        <title>LDAP: Active Directory (AD) </title>
        <link type="text/css" href="../vendor/twbs/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>

    <body>
        <div class="container">
            <form action method="POST">
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label" for="server">Server: </label>
                    <div class="col-sm-10">
                        <input id="server" name="server" type="text" value="192.168.1.105">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label" for="domain">Domain: </label>
                    <div class="col-sm-10">
                        <input id="domain" name="domain" type="text" value="phunsanit">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label" for="username">Username: </label>
                    <div class="col-sm-10">
                        <input id="username" name="username" type="text" value="pitt.p">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label" for="password">Password: </label>
                    <div class="col-sm-10">
                        <input id="password" name="password" type="password" value="oz363389">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label" for="search">Search: </label>
                    <div class="col-sm-10">
                        <input id="search" name="search" type="text" value="dc=phunsanit">
                    </div>
                </div>
                <div class="form-group row">
                    <div class="col-sm-10">
                        <button class="btn btn-primary" type="submit">Sign in</button>
                    </div>
                </div>
            </form>
        </div>
        server: ' . $adServer . '<br>bind: ' . $ldaprdn . ' ' . $password . '<br>search: ' . $search . '<br>filter: ' . $filter;

    $ldap = ldap_connect($adServer);
    ldap_set_option($ldap, LDAP_OPT_PROTOCOL_VERSION, 3);
    ldap_set_option($ldap, LDAP_OPT_REFERRALS, 0);
    $bind = @ldap_bind($ldap, $ldaprdn, $password);
    if ($bind) {
        echo '<br>Connect';
        $result = ldap_search($ldap, $search, $filter);
        $info = ldap_get_entries($ldap, $result);
        for ($i = 0; $i < $info['count']; $i++) {
            if ($info['count'] > 1) {
                break;
            }
            echo '<br>You are accessing <strong> ' . $info[$i]['sn'][0] . ', ' . $info[$i]['givenname'][0] . '</strong><br> (' . $info[$i]['samaccountname'][0] . ')<p></p><pre>' . print_r($info, true) . '</pre>';
            $userDn = $info[$i]['distinguishedname'][0];
        }
        @ldap_close($ldap);
    } else {
        $msg = '<br>Invalid email address / password';
        echo $msg;
    }
}
?>
    </body>

    </html>
