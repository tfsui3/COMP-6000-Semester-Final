<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta charset="UTF-8">
	<title>Personal information</title>
	<link rel="stylesheet" type="text/css" href="easyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="easyui/themes/icon.css">
	<link rel="stylesheet" type="text/css" href="easyui/css/demo.css">
	
	<style type="text/css">
		.table th{font-weight:bold}
		.table th,.table td{padding:8px;line-height:20px}
		.table td{text-align:left}
		.table-border{border-top:1px solid #ddd}
		.table-border th,.table-border td{border-bottom:1px solid #ddd}
		.table-bordered{border:1px solid #ddd;border-collapse:separate;*border-collapse:collapse;border-left:0}
		.table-bordered th,.table-bordered td{border-left:1px solid #ddd}
		.table-border.table-bordered{border-bottom:0}
		.table-striped tbody > tr:nth-child(odd) > td,.table-striped tbody > tr:nth-child(odd) > th{background-color:#f9f9f9}
	</style>
	
	<script type="text/javascript" src="easyui/jquery.min.js"></script>
	<script type="text/javascript" src="easyui/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="easyui/js/validateExtends.js"></script>
	<script type="text/javascript">
	$(function() {	
		
		//Edit Password
	    $("#passwordDialog").dialog({
	    	title: "Change password",
	    	width: 500,
	    	height: 300,
	    	iconCls: "icon-add",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	  	    		{
	  					text:'Submit',
	  					iconCls:'icon-user_add',
	  					handler:function(){
	  						var validate = $("#editPassword").form("validate");
	  						if(!validate){
	  							$.messager.alert("Message reminder","Please check the data you entered!","warning");
	  							return;
	  						} else{
	  							$.ajax({
	  								type: "post",
	  								url: "SystemServlet?method=EditPasswod&t="+new Date().getTime(),
	  								data: $("#editPassword").serialize(),
	  								success: function(msg){
	  									if(msg == "success"){
	  										$.messager.alert("Message reminder","If the change is successful, log in again","info")
	  										setTimeout(function(){
	  											top.location.href = "LoginServlet?method=logout";
	  										}, 1000);
	  									}else{
	  										$.messager.alert("Message reminder",msg,"error")
	  									}
	  								}
	  							});
	  						}
	  					}
	  				},
	  				{
	  					text:'reset',
	  					iconCls:'icon-reload',
	  					handler:function(){
	  						$("#old_password").textbox('setValue', "");
	  						$("#new_password").textbox('setValue', "");
	  						$("#re_password").textbox('setValue', "");
	  					}
	  				}
	  			],
	    })
		
	    $("#editDialog").dialog({
	    	title: "Change password",
	    	width: 500,
	    	height: 400,
	    	fit: true,
	    	modal: false,
	    	noheader: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: false,
	    	toolbar: [
				{
					text:'Change password',
					plain: true,
					iconCls:'icon-password',
					handler:function(){
						$("#passwordDialog").dialog("open");
					}
				}
			],
			
	    });
		
	    setTimeout(function(){
	    	$("#passwordDialog").dialog("open");
	    },1000);
		
		
	})
	</script>
</head>
<body>
	
	<div id="editDialog" style="padding: 20px;">
		
	</div>
	
	<div id="passwordDialog" style="padding: 20px">
    	<form id="editPassword">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td>Original password:</td>
	    			<td>
	    				<input id="old_password" name="password" style ="width: 200px; height: 30px;" class="easyui-textbox" type="password"  data-options="required:true, missingMessage:'Please enter the old password'" />
	    			</td>
	    		</tr>
	    		<tr>
	    			<td>New password:</td>
	    			<td>
	    				<input id="new_password" style="width: 200px; height: 30px;" class="easyui-textbox" type="password" validType="password" name="newpassword" data-options="required:true, missingMessage:'Please enter a new password'" />
	    			</td>
	    		</tr>
	    		<tr>
	    			<td>New password:</td>
	    			<td><input id="re_password" style="width: 200px; height: 30px;" class="easyui-textbox" type="password" validType="equals['#new_password']"  data-options="required:true, missingMessage:'Reenter the password'" /></td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
</body>
</html>