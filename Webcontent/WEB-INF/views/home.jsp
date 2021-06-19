<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page session="false"%>
<html>
<head>
    <title>Home</title>
</head>
<body>
<h1>Hello world!</h1>

<P>现在时间是: ${serverTime}.</p><br>

<form action="user" method="post">
    <tr>
        <td>请输入用户名：</td>
    <input type="text" name="userName"><br><br>
    <input type="submit" value="Login">
    </tr>
</form>
</body>
</html>
