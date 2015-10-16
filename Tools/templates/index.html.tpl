<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
        <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black" />

        <link rel="apple-touch-icon" href="Resources/icon.png" />
        <link rel="apple-touch-startup-image" href="Resources/default.png" />
        <link rel="shortcut icon" type="image/png" href="Resources/Branding/favicon.ico" />

        <link href='Resources/app.css' rel='stylesheet' type='text/css'>

        <title>{{app_name}}</title>

        <script type="text/javascript">
            var progressBar = null;

            OBJJ_PROGRESS_CALLBACK = function(percent, appSize, path)
            {
                percent = percent * 100;

                if (!progressBar)
                    progressBar = document.getElementById("progress-bar");

                if (progressBar)
                    progressBar.style.width = Math.min(percent, 100) + "%";
            }

        </script>

        <!--[if IE gt 10]-->
        <script type="text/javascript" src="Frameworks/Objective-J/Objective-J.js" charset="UTF-8"></script>
        <!--[endif]-->

    </head>

    <body style="background-image: url(Resources/Branding/background.jpg) ">
        <div id="cappuccino-body">
            <div id="loadingcontainer">
                <div id="logo"></div>

                <!--[if IE gt 10]-->
                <div id="loading">
                    <div id="loading-text"></div>
                    <div id="progress-indicator">
                        <span id="progress-bar" style="width:0%"></span>
                    </div>
                </div>
                <!--[endif]-->

                <!--[if IE lte 10]>
                <div id="loading" style="width: 400px; margin-left: -30px">
                    <span style="text-align:center; color:white">browser not supported</span>
                </div>
                <![endif]-->

            </div>
            <noscript style="position:absolute; top:0; left:0; width:100%; height:100%">
                <div class="container">
                    <div class="content">
                        <div id="noscript">
                            <p style="font-size:120%; margin-bottom:.75em">JavaScript is required for this site.</p>
                            <p><a href="http://www.enable-javascript.com" target="_blank">Enable JavaScript</a></p>
                        </div>
                    </div>
                </div>
            </noscript>
        </div>
    </body>

</html>
