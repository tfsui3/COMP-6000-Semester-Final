<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta charset="UTF-8">
	<title>Student List</title>
	<link rel="stylesheet" type="text/css" href="easyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="easyui/themes/icon.css">
	<link rel="stylesheet" type="text/css" href="easyui/css/demo.css">
	<script type="text/javascript" src="easyui/jquery.min.js"></script>
	<script type="text/javascript" src="easyui/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="easyui/js/validateExtends.js"></script>
	<script type="text/javascript">
	$(function() {	
		//datagrid generation
	    $('#dataList').datagrid({ 
	        title:'Student list', 
	        iconCls:'icon-more',//Icon
	        border: true, 
	        collapsible:false,//collapsible or not 
	        fit: true,
	        method: "post",
	        url:"StudentServlet?method=StudentList&t="+new Date().getTime(),
	        idField:'id', 
	        singleSelect:false,
	        pagination:true, 
	        rownumbers:true, 
	        sortName:'id',
	        sortOrder:'DESC', 
	        remoteSort: false,
	        columns: [[  
				{field:'chk',checkbox: true,width:50},
 		        {field:'id',title:'ID',width:50, sortable: true},    
 		        {field:'sn',title:'sn',width:200, sortable: true},    
 		        {field:'name',title:'name',width:200},
 		        {field:'sex',title:'sex',width:100},
 		        {field:'mobile',title:'mobile',width:150},
 		        {field:'email',title:'Email',width:150},
 		        {field:'clazz_id',title:'class',width:150, 
 		        	formatter: function(value,row,index){
 						if (row.clazzId){
 							var clazzList = $("#clazzList").combobox("getData");
 							for(var i=0;i<clazzList.length;i++ ){
 								//console.log(clazzList[i]);
 								if(row.clazzId == clazzList[i].id)return clazzList[i].name;
 							}
 							return row.clazzId;
 						} else {
 							return 'not found';
 						}
 					}
				},
 		        
	 		]], 
	        toolbar: "#toolbar",
	        onBeforeLoad : function(){
	        	try{
	        		$("#clazzList").combobox("getData")
	        	}catch(err){
	        		preLoadClazz();
	        	}
	        }
	    }); 
	    //Paging
	    var p = $('#dataList').datagrid('getPager'); 
	    $(p).pagination({ 
	        pageSize: 10,//The size of each page, assume it is 10
	        pageList: [10,20,30,50,100],
	        beforePageText: 'the first',
	        afterPageText: 'page    total {pages} page', 
	        displayMsg: 'Current display {from} - {to} records    {total} Bar record', 
	    }); 
	    $("#add").click(function(){
	    	$("#addDialog").dialog("open");
	    });
	    $("#edit").click(function(){
	    	var selectRows = $("#dataList").datagrid("getSelections");
        	if(selectRows.length != 1){
            	$.messager.alert("Message reminder", "Select a piece of data to operate!", "warning");
            } else{
		    	$("#editDialog").dialog("open");
            }
	    });
	    $("#delete").click(function(){
	    	var selectRows = $("#dataList").datagrid("getSelections");
        	var selectLength = selectRows.length;
        	if(selectLength == 0){
            	$.messager.alert("Message reminder", "Select data to delete!", "warning");
            } else{
            	var numbers = [];
            	$(selectRows).each(function(i, row){
            		numbers[i] = row.sn;
            	});
            	var ids = [];
            	$(selectRows).each(function(i, row){
            		ids[i] = row.id;
            	});
            	$.messager.confirm("Message reminder", "All data related to the student (including grades) will be deleted and confirmed to continue？", function(r){
            		if(r){
            			$.ajax({
							type: "post",
							url: "StudentServlet?method=DeleteStudent",
							data: {sns: numbers, ids: ids},
							success: function(msg){
								if(msg == "success"){
									$.messager.alert("Message reminder","Deleted successfully!","info");
									//Refresh
									$("#dataList").datagrid("reload");
									$("#dataList").datagrid("uncheckAll");
								} else{
									$.messager.alert("Message reminder","Deletion failure!","warning");
									return;
								}
							}
						});
            		}
            	});
            }
	    });
	    
	  	
	  	//
	  	/*$("#clazzList").combobox({
	  		width: "150",
	  		height: "25",
	  		valueField: "id",
	  		textField: "name",
	  		multiple: false, 
	  		editable: false, 
	  		method: "post",
	  		url: "ClazzServlet?method=getClazzList&t="+new Date().getTime()+"&from=combox",
	  		onChange: function(newValue, oldValue){
	  			$('#dataList').datagrid("options").queryParams = {clazzid: newValue};
	  			$('#dataList').datagrid("reload");
	  		}
	  	});*/
	  	
	  	function preLoadClazz(){
	  		$("#clazzList").combobox({
		  		width: "150",
		  		height: "25",
		  		valueField: "id",
		  		textField: "name",
		  		multiple: false, 
		  		editable: false, 
		  		method: "post",
		  		url: "ClazzServlet?method=getClazzList&t="+new Date().getTime()+"&from=combox",
		  		onChange: function(newValue, oldValue){
		  			//$('#dataList').datagrid("options").queryParams = {clazzid: newValue};
		  			//$('#dataList').datagrid("reload");
		  		}
		  	});
	  	}
	  	
	  	$("#add_clazzList, #edit_clazzList").combobox({
	  		width: "200",
	  		height: "30",
	  		valueField: "id",
	  		textField: "name",
	  		multiple: false, 
	  		editable: false,
	  		method: "post",
	  	});
	  	
	  	
	  	$("#add_clazzList").combobox({
	  		url: "ClazzServlet?method=getClazzList&t="+new Date().getTime()+"&from=combox",
	  		onLoadSuccess: function(){
				var data = $(this).combobox("getData");;
				$(this).combobox("setValue", data[0].id);
	  		}
	  	});
	  	
	  	
	  	
	  	$("#edit_clazzList").combobox({
	  		url: "ClazzServlet?method=getClazzList&t="+new Date().getTime()+"&from=combox",
			onLoadSuccess: function(){
				var data = $(this).combobox("getData");
				$(this).combobox("setValue", data[0].id);
	  		}
	  	});
	  	
	    $("#addDialog").dialog({
	    	title: "Add students",
	    	width: 650,
	    	height: 460,
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
					iconCls:'icon-user_add',
					handler:function(){
						var validate = $("#addForm").form("validate");
						if(!validate){
							$.messager.alert("Message reminder","Please check the data you entered!","warning");
							return;
						} else{
							var clazzid = $("#add_clazzList").combobox("getValue");
							$.ajax({
								type: "post",
								url: "StudentServlet?method=AddStudent",
								data: $("#addForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("Message reminder","Add successfully!","info");
										$("#addDialog").dialog("close");
										$("#add_number").textbox('setValue', "");
										$("#add_name").textbox('setValue', "");
										$("#add_sex").textbox('setValue', "Male");
										$("#add_phone").textbox('setValue', "");
										$("#add_email").textbox('setValue', "");
										
										$('#dataList').datagrid("options").queryParams = {clazzid: clazzid};
							  			$('#dataList').datagrid("reload");
							  			setTimeout(function(){
											$("#clazzList").combobox('setValue', clazzid);
										}, 100);
										
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
						$("#add_number").textbox('setValue', "");
						$("#add_name").textbox('setValue', "");
						$("#add_phone").textbox('setValue', "");
						$("#add_email").textbox('setValue', "");
						$("#add_gradeList").combobox("clear");
						$("#add_gradeList").combobox("reload");
					}
				},
			]
	    });
	  	
	    $("#editDialog").dialog({
	    	title: "Modify student information",
	    	width: 650,
	    	height: 460,
	    	iconCls: "icon-edit",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	    		{
					text:'submit',
					plain: true,
					iconCls:'icon-user_add',
					handler:function(){
						var validate = $("#editForm").form("validate");
						var clazzid = $("#edit_clazzList").combobox("getValue");
						if(!validate){
							$.messager.alert("Message reminder","Please check the data you entered!","warning");
							return;
						} else{
							$.ajax({
								type: "post",
								url: "StudentServlet?method=EditStudent&t="+new Date().getTime(),
								data: $("#editForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("Message reminder","Update successfully!","info");
										$("#editDialog").dialog("close");
										$('#dataList').datagrid("options").queryParams = {clazzid: clazzid};
										$("#dataList").datagrid("reload");
										$("#dataList").datagrid("uncheckAll");
										
							  			setTimeout(function(){
											$("#clazzList").combobox('setValue', clazzid);
										}, 100);
							  			
									} else{
										$.messager.alert("Message reminder","Update failure!","warning");
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
						$("#edit_sex").textbox('setValue', "male");
						$("#edit_phone").textbox('setValue', "");
						$("#edit_email").textbox('setValue', "");
						$("#edit_gradeList").combobox("clear");
						$("#edit_gradeList").combobox("reload");
					}
				}
			],
			onBeforeOpen: function(){
				var selectRow = $("#dataList").datagrid("getSelected");
				$("#edit_name").textbox('setValue', selectRow.name);
				$("#edit_sex").textbox('setValue', selectRow.sex);
				$("#edit_mobile").textbox('setValue', selectRow.mobile);
				$("#edit_email").textbox('setValue', selectRow.email);
				$("#edit_photo").attr("src", "PhotoServlet?method=getPhoto&type=2&sid="+selectRow.id);
				$("#edit-id").val(selectRow.id);
				$("#set-photo-id").val(selectRow.id);
				var clazzid = selectRow.clazzId;
				setTimeout(function(){
					$("#edit_clazzList").combobox('setValue', clazzid);
				}, 100);
				
			}
	    });
	  	$("#search-btn").click(function(){
	  		$('#dataList').datagrid('load',{
	  			studentName: $('#search_student_name').val(),
	  			clazzid: $("#clazzList").combobox('getValue') == '' ? 0 : $("#clazzList").combobox('getValue')
	  		});
	  	});
	});
	$("#upload-photo-btn").click(function(){
		
	});
	function uploadPhoto(){
		var action = $("#uploadForm").attr('action');
		var pos = action.indexOf('sid');
		if(pos != -1){
			action = action.substring(0,pos-1);
		}
		$("#uploadForm").attr('action',action+'&sid='+$("#set-photo-id").val());
		$("#uploadForm").submit();
		setTimeout(function(){
			var message =  $(window.frames["photo_target"].document).find("#message").text();
			$.messager.alert("Message reminder",message,"info");
			
			$("#edit_photo").attr("src", "PhotoServlet?method=getPhoto&sid="+$("#set-photo-id").val());
		}, 1500)
	}
	</script>
</head>
<body>
	<!-- Student List -->
	<table id="dataList" cellspacing="0" cellpadding="0"> 
	    
	</table> 
	<!-- Tool bar -->
	<div id="toolbar">
	    <c:if test="${userType == 1 || userType == 3}">
	        <div style="float: left;">
	            <a id="add" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">add</a>
	        </div>
	        <div style="float: left;" class="datagrid-btn-separator"></div>
	    </c:if>
	    <div style="float: left;">
	        <a id="edit" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true">update</a>
	    </div>
	    <div style="float: left;" class="datagrid-btn-separator"></div>
	    <c:if test="${userType == 1 || userType == 3}">
	        <div style="float: left;">
	            <a id="delete" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-some-delete',plain:true">delete</a>
	        </div>
	    </c:if>
	    <div style="float: left;margin-top:4px;" class="datagrid-btn-separator">&nbsp;&nbsp;Name：<input id="search_student_name" class="easyui-textbox" name="search_student_name"/></div>
	    <div style="margin-left: 10px;margin-top:4px;">class：<input id="clazzList" class="easyui-textbox" name="clazz"/>
	        <a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">search</a>
	    </div>
	</div>
		
	<!-- Add Student Window -->
	<div id="addDialog" style="padding: 10px">  
		<div style="float: right; margin: 20px 20px 0 0; width: 200px; border: 1px solid #EBF3FF" id="photo">
	    	<img alt="photograph" style="max-width: 200px; max-height: 400px;" title="photograph" src="PhotoServlet?method=getPhoto" />
	    </div> 
    	<form id="addForm" method="post">
	    	<table cellpadding="8" >
	    		
	    		<tr>
	    			<td>Name:</td>
	    			<td><input id="add_name" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="name" data-options="required:true, missingMessage:'Please enter name'" /></td>
	    		</tr>
	    		<tr>
	    			<td>Password:</td>
	    			<td>
	    				<input id="add_password"  class="easyui-textbox" style="width: 200px; height: 30px;" type="password" name="password" data-options="required:true, missingMessage:'Please enter password'" />
	    			</td>
	    		</tr>
	    		<tr>
	    			<td>Gender:</td>
	    			<td><select id="add_sex" class="easyui-combobox" data-options="editable: false, panelHeight: 50, width: 60, height: 30" name="sex"><option value="Male">Male</option><option value="Female">Female</option></select></td>
	    		</tr>
	    		<tr>
	    			<td>Phone:</td>
	    			<td><input id="add_phone" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="mobile" validType="mobile" /></td>
	    		</tr>
	    		<tr>
	    			<td>Email:</td>
	    			<td><input id="add_email" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="email" validType="number" /></td>
	    		</tr>
	    		<tr>
	    			<td>Major:</td>
	    			<td><input id="add_clazzList" style="width: 200px; height: 30px;" class="easyui-textbox" name="clazzid" /></td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
	<!-- Edit Student -->
	<div id="editDialog" style="padding: 10px">
		<div style="float: right; margin: 20px 20px 0 0; width: 200px; border: 1px solid #EBF3FF">
	    	<img id="edit_photo" alt="photograph" style="max-width: 200px; max-height: 400px;" title="photograph" src="" />
	    	<form id="uploadForm" method="post" enctype="multipart/form-data" action="PhotoServlet?method=SetPhoto" target="photo_target">
	    		<!-- StudentServlet?method=SetPhoto -->
	    		<input type="hidden" name="sid" id="set-photo-id">
		    	<input class="easyui-filebox" name="photo" data-options="prompt:'Select photo'" style="width:200px;">
		    	<input id="upload-photo-btn" onClick="uploadPhoto()" class="easyui-linkbutton" style="width: 50px; height: 24px;" type="button" value="upload"/>
		    </form>
	    </div>   
    	<form id="editForm" method="post">
	    	<input type="hidden" name="id" id="edit-id">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td>name:</td>
	    			<td><input id="edit_name" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="name" data-options="required:true, missingMessage:'Please fill in your name'" /></td>
	    		</tr>
	    		<tr>
	    			<td>gender:</td>
	    			<td><select id="edit_sex" class="easyui-combobox" data-options="editable: false, panelHeight: 50, width: 60, height: 30" name="sex"><option value="male">male</option><option value="female">female</option></select></td>
	    		</tr>
	    		<tr>
	    			<td>telephone:</td>
	    			<td><input id="edit_mobile" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="mobile" validType="mobile" /></td>
	    		</tr>
	    		<tr>
	    			<td>email:</td>
	    			<td><input id="edit_email" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="email" validType="number" /></td>
	    		</tr>
	    		<tr>
	    			<td>class:</td>
	    			<td><input id="edit_clazzList" style="width: 200px; height: 30px;" class="easyui-textbox" name="clazzid" /></td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	<iframe id="photo_target" name="photo_target"></iframe>  
</body>
</html>