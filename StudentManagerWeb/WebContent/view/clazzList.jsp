<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta charset="UTF-8">
	<title>Class list</title>
	<link rel="stylesheet" type="text/css" href="easyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="easyui/themes/icon.css">
	<link rel="stylesheet" type="text/css" href="easyui/css/demo.css">
	<script type="text/javascript" src="easyui/jquery.min.js"></script>
	<script type="text/javascript" src="easyui/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="easyui/js/validateExtends.js"></script>
	<script type="text/javascript">
	$(function() {	
	    $('#dataList').datagrid({ 
	        title:'Class list', 
	        iconCls:'icon-more',
	        border: true, 
	        collapsible: false,
	        fit: true, 
	        method: "post",
	        url:"ClazzServlet?method=getClazzList&t="+new Date().getTime(),
	        idField:'id', 
	        singleSelect: true,
	        pagination: true, 
	        rownumbers: true,
	        sortName: 'id',
	        sortOrder: 'DESC', 
	        remoteSort: false,
	        columns: [[  
				{field:'chk',checkbox: true,width:50},
 		        {field:'id',title:'ID',width:50, sortable: true},    
 		        {field:'name',title:'Class name',width:200},
 		        {field:'info',title:'Class introduction',width:100, 
 		        },
	 		]], 
	        toolbar: "#toolbar"
	    }); 
	    var p = $('#dataList').datagrid('getPager'); 
	    $(p).pagination({ 
	        pageSize: 10,
	        pageList: [10,20,30,50,100],
	        beforePageText: 'the first',
	        afterPageText: 'page    total {pages} page', 
	        displayMsg: 'Current display {from} - {to} Bar record   total {total} Bar record', 
	    });
	    $("#add").click(function(){
	    	$("#addDialog").dialog("open");
	    });
	    $("#delete").click(function(){
	    	var selectRow = $("#dataList").datagrid("getSelected");
	    	//console.log(selectRow);
        	if(selectRow == null){
            	$.messager.alert("Message reminder", "Select data to delete!", "warning");
            } else{
            	var clazzid = selectRow.id;
            	$.messager.confirm("Message reminder", "The class information will be deleted (cannot be deleted if there are students or teachers in the class). Confirm to continue?", function(r){
            		if(r){
            			$.ajax({
							type: "post",
							url: "ClazzServlet?method=DeleteClazz",
							data: {clazzid: clazzid},
							success: function(msg){
								if(msg == "success"){
									$.messager.alert("Message reminder","Deleted successfully!","info");
									$("#dataList").datagrid("reload");
								} else{
									$.messager.alert("Message reminder","Deleted failed!","warning");
									return;
								}
							}
						});
            		}
            	});
            }
	    });
	    
	    
	    $("#addDialog").dialog({
	    	title: "Add class",
	    	width: 500,
	    	height: 400,
	    	iconCls: "icon-add",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	    		{
					text:'add',
					plain: true,
					iconCls:'icon-add',
					handler:function(){
						var validate = $("#addForm").form("validate");
						if(!validate){
							$.messager.alert("Message reminder","Please check the data you entered!","warning");
							return;
						} else{
							//var gradeid = $("#add_gradeList").combobox("getValue");
							$.ajax({
								type: "post",
								url: "ClazzServlet?method=AddClazz",
								data: $("#addForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("Message reminder","Add successfully!","info");
										$("#addDialog").dialog("close");
										$("#add_name").textbox('setValue', "");
										$("#info").val("");
							  			//$('#gradeList').combobox("setValue", gradeid);
							  			$('#dataList').datagrid("reload");
										
									} else{
										$.messager.alert("Message reminder","Add failure!","warning");
										return;
									}
								}
							});
						}
					}
				},
				{
					text:'reset',
					plain: true,
					iconCls:'icon-reload',
					handler:function(){
						$("#add_name").textbox('setValue', "");
						$("#info").val("");
					}
				},
			]
	    });
	  	
	  	$("#search-btn").click(function(){
	  		$('#dataList').datagrid('load',{
	  			clazzName: $('#clazzName').val()
	  		});
	  	});
	  	
	  	$("#edit-btn").click(function(){
	  		var selectRow = $("#dataList").datagrid("getSelected");
	    	//console.log(selectRow);
        	if(selectRow == null){
            	$.messager.alert("Message reminder", "Select data to modify!", "warning");
            	return;
            }
        	$("#editDialog").dialog("open");
	  	});
	  
	    $("#editDialog").dialog({
	    	title: "Editing class",
	    	width: 500,
	    	height: 400,
	    	iconCls: "icon-add",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	    		{
					text:'Definite modification',
					plain: true,
					iconCls:'icon-add',
					handler:function(){
						var validate = $("#editForm").form("validate");
						if(!validate){
							$.messager.alert("Message reminder","Please check the data you entered!","warning");
							return;
						} else{
							//var gradeid = $("#add_gradeList").combobox("getValue");
							$.ajax({
								type: "post",
								url: "ClazzServlet?method=EditClazz",
								data: $("#editForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("Message reminder","Modified successfully!","info");
										$("#editDialog").dialog("close");
										$("#edit_name").textbox('setValue', "");
										$("#edit_info").val("");
							  			//$('#gradeList').combobox("setValue", gradeid);
							  			$('#dataList').datagrid("reload");
										
									} else{
										$.messager.alert("Message reminder","Modified failuer!","warning");
										return;
									}
								}
							});
						}
					}
				},
				{
					text:'reset',
					plain: true,
					iconCls:'icon-reload',
					handler:function(){
						$("#edit_name").textbox('setValue', "");
						$("#edit_info").val("");
					}
				},
			],
			onBeforeOpen: function(){
				var selectRow = $("#dataList").datagrid("getSelected");
				//console.log(selectRow);
				$("#edit_name").textbox('setValue', selectRow.name);
				$("#edit_info").val(selectRow.info);
				$("#edit-id").val(selectRow.id);
			}
	    });
	  
	});
	</script>
</head>
<body>
	<table id="dataList" cellspacing="0" cellpadding="0"> 
	</table> 
	
	<div id="toolbar">
		<div style="float: left;"><a id="add" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">add</a></div>
		<div style="float: left; margin-right: 10px;"><a id="edit-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true">update</a></div>
		<div style="float: left; margin-right: 10px;"><a id="delete" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-some-delete',plain:true">delete</a></div>
		<div style="margin-top: 3px;">Class name：<input id="clazzName" class="easyui-textbox" name="clazzName" />
			<a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">search</a>
		</div>
	</div>
	
	<div id="addDialog" style="padding: 10px">  
    	<form id="addForm" method="post">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td>Class name:</td>
	    			<td><input id="add_name" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="name"  data-options="required:true, missingMessage:'is not null'" /></td>
	    		</tr>
	    		<tr>
	    			<td>Class introduction:</td>
	    			<td>
	    				<textarea id="info" name="info" style="width: 200px; height: 60px;" class="" ></textarea>
	    			</td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
	<div id="editDialog" style="padding: 10px">  
    	<form id="editForm" method="post">
    	<input type="hidden" id="edit-id" name="id">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td>Class name:</td>
	    			<td><input id="edit_name" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="name"  data-options="required:true, missingMessage:'is not null'" /></td>
	    		</tr>
	    		<tr>
	    			<td>Class introduction:</td>
	    			<td>
	    				<textarea id="edit_info" name="info" style="width: 200px; height: 60px;" class="" ></textarea>
	    			</td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
</body>
</html>