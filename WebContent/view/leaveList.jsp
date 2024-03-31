<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta charset="UTF-8">
	<title>Leave list</title>
	<link rel="stylesheet" type="text/css" href="easyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="easyui/themes/icon.css">
	<link rel="stylesheet" type="text/css" href="easyui/css/demo.css">
	<script type="text/javascript" src="easyui/jquery.min.js"></script>
	<script type="text/javascript" src="easyui/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="easyui/js/validateExtends.js"></script>
	<script type="text/javascript">
	$(function() {	
	    $('#dataList').datagrid({ 
	        title:'Leave list', 
	        iconCls:'icon-more',
	        border: true, 
	        collapsible: false,
	        fit: true,
	        method: "post",
	        url:"LeaveServlet?method=LeaveList&t="+new Date().getTime(),
	        idField:'id', 
	        singleSelect: true,
	        pagination: true,
	        rownumbers: true,
	        sortName:'id',
	        sortOrder:'DESC', 
	        remoteSort: false,
	        columns: [[  
				{field:'chk',checkbox: true,width:50},
 		        {field:'id',title:'ID',width:50, sortable: true},    
 		       	{field:'studentID',title:'student',width:200,
 		        	formatter: function(value,row,index){
 						if (row.studentId){
 							var studentList = $("#studentList").combobox("getData");
 							for(var i=0;i<studentList.length;i++ ){
 								//console.log(clazzList[i]);
 								if(row.studentId == studentList[i].id)return studentList[i].name;
 							}
 							return row.studentId;
 						} else {
 							return 'not found';
 						}
 					}	
 		       	},
 		       	{field:'info',title:'Reason for leave',width:400},
 		        {field:'status',title:'Status',width:80,
 		       	formatter: function(value,row,index){
						switch(row.status){
							case 0:{
								return 'wait for review';
							}
							case 1:{
								return 'pass the review';
							}
							case -1:{
								return 'no pass the review';
							}
						}
					}	
 		        },
 		        {field:'remark',title:'Content of approval',width:400},
	 		]], 
	        toolbar: "#toolbar",
	        onBeforeLoad : function(){
	        	try{
	        		$("#studentList").combobox("getData")
	        	}catch(err){
	        		preLoadClazz();
	        	}
	        }
	    }); 
	    function preLoadClazz(){
	  		$("#studentList").combobox({
		  		width: "150",
		  		height: "25",
		  		valueField: "id",
		  		textField: "name",
		  		multiple: false, 
		  		editable: false, 
		  		method: "post",
		  		url: "StudentServlet?method=StudentList&t="+new Date().getTime()+"&from=combox",
		  		onChange: function(newValue, oldValue){
		  			//$('#dataList').datagrid("options").queryParams = {clazzid: newValue};
		  			//$('#dataList').datagrid("reload");
		  		}
		  	});
	  	}
		
	    var p = $('#dataList').datagrid('getPager'); 
	    $(p).pagination({ 
	        pageSize: 10,
	        pageList: [10,20,30,50,100],
	        beforePageText: 'the firsr',
	        afterPageText: 'page   total{pages} page', 
	        displayMsg: 'Current display {from} - {to} Bar record   total {total} Bar record', 
	    });
	   	
	    $("#add").click(function(){
	    	$("#addDialog").dialog("open");
	    });
	    
	    $("#edit").click(function(){
	    	var selectRows = $("#dataList").datagrid("getSelections");
        	if(selectRows.length != 1){
            	$.messager.alert("Message reminder", "Select a piece of data to operate!", "warning");
            } else{
            	if(selectRows[0].status != 0){
            		$.messager.alert("Message reminder", "The leave information has been reviewed and cannot be modified!", "warning");
            		return;
            	}
		    	$("#editDialog").dialog("open");
            }
	    });
	  
	    $("#check").click(function(){
	    	var selectRows = $("#dataList").datagrid("getSelections");
        	if(selectRows.length != 1){
            	$.messager.alert("Message reminder", "Select a piece of data to operate!", "warning");
            } else{
            	if(selectRows[0].status != 0){
            		$.messager.alert("Message reminder", "This leave information has been reviewed, please do not repeat the review!", "warning");
            		return;
            	}
		    	$("#checkDialog").dialog("open");
            }
	    });
	    
	  	$("#editDialog").dialog({
	  		title: "Modify leave information",
	    	width: 450,
	    	height: 350,
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
					iconCls:'icon-add',
					handler:function(){
						var validate = $("#editForm").form("validate");
						if(!validate){
							$.messager.alert("Message reminder","Please check the data you entered!","warning");
							return;
						} else{
							var studentid = $("#edit_studentList").combobox("getValue");
							var id = $("#dataList").datagrid("getSelected").id;
							var info = $("#edit_info").textbox("getValue");
							var data = {id:id, studentid:studentid, info:info};
							
							$.ajax({
								type: "post",
								url: "LeaveServlet?method=EditLeave",
								data: data,
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("Message reminder","Modified successfully!","info");
										$("#editDialog").dialog("close");
										$("#edit_info").textbox('setValue',"");
										
							  			$('#dataList').datagrid("reload");
							  			$('#dataList').datagrid("uncheckAll");
										
									} else{
										$.messager.alert("Message reminder","Modification failure!","warning");
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
						$("#edit_info").val("");
					}
				},
			],
			onBeforeOpen: function(){
				var selectRow = $("#dataList").datagrid("getSelected");
				$("#edit_info").textbox('setValue',selectRow.info);
				//$("#edit-id").val(selectRow.id);
				var studentId = selectRow.studentId;
				setTimeout(function(){
					$("#edit_studentList").combobox('setValue', studentId);
				}, 100);
			},
			onClose: function(){
				$("#edit_info").val("");
				//$("#edit-id").val('');
			}
	    });
	  
	  
	  	$("#checkDialog").dialog({
	  		title: "Review leave information",
	    	width: 450,
	    	height: 350,
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
					iconCls:'icon-add',
					handler:function(){
						var validate = $("#checkForm").form("validate");
						if(!validate){
							$.messager.alert("Message reminder","Please check the data you entered!","warning");
							return;
						} else{
							
							var studentid = $("#dataList").datagrid("getSelected").studentId;
							var id = $("#dataList").datagrid("getSelected").id;
							var info = $("#dataList").datagrid("getSelected").info;
							var remark = $("#check_remark").textbox("getValue");
							var status = $("#check_statusList").combobox("getValue");
							var data = {id:id, studentid:studentid, info:info,remark:remark,status:status};
							
							$.ajax({
								type: "post",
								url: "LeaveServlet?method=CheckLeave",
								data: data,
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("Message reminder","Successful review!","info");
										$("#checkDialog").dialog("close");
										$("#check_remark").textbox('setValue',"");
										
							  			$('#dataList').datagrid("reload");
							  			$('#dataList').datagrid("uncheckAll");
										
									} else{
										$.messager.alert("Message reminder","failure review!","warning");
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
						$("#check_remark").val("");
						$("#check_statusList").combox('clear');
					}
				},
			],
			onBeforeOpen: function(){
				/*
				var selectRow = $("#dataList").datagrid("getSelected");
				$("#edit_info").textbox('setValue',selectRow.info);
				//$("#edit-id").val(selectRow.id);
				var studentId = selectRow.studentId;
				setTimeout(function(){
					$("#edit_studentList").combobox('setValue', studentId);
				}, 100);*/
			},
			onClose: function(){
				$("#edit_info").val("");
				//$("#edit-id").val('');
			}
	    });
	    
	    $("#delete").click(function(){
	    	var selectRow = $("#dataList").datagrid("getSelected");
        	if(selectRow == null){
            	$.messager.alert("Message reminder", "Select data to delete!", "warning");
            } else{
            	$.messager.confirm("Message reminder", "Are you sure you want to delete it? Go ahead?", function(r){
            		if(r){
            			$.ajax({
							type: "post",
							url: "LeaveServlet?method=DeleteLeave",
							data: {id: selectRow.id},
							success: function(msg){
								if(msg == "success"){
									$.messager.alert("Message reminder","Deleted successfully!","info");
									$("#dataList").datagrid("reload");
								} else{
									$.messager.alert("Message reminder","Deleted failure!","warning");
									return;
								}
							}
						});
            		}
            	});
            }
	    });
	  	
	    $("#addDialog").dialog({
	    	title: "Add a leave slip",
	    	width: 450,
	    	height: 350,
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
					iconCls:'icon-book-add',
					handler:function(){
						var validate = $("#addForm").form("validate");
						if(!validate){
							$.messager.alert("Message reminder","Please check the data you entered!","warning");
							return;
						} else{
							$.ajax({
								type: "post",
								url: "LeaveServlet?method=AddLeave",
								data: $("#addForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("Message reminder","Add successfully!","info");
										$("#addDialog").dialog("close");
										//$("#add_name").textbox('setValue', "");
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
					iconCls:'icon-book-reset',
					handler:function(){
						$("#add_name").textbox('setValue', "");
					}
				},
			]
	    });
	  	
	  	$("#add_studentList, #edit_studentList,#studentList").combobox({
	  		width: "200",
	  		height: "30",
	  		valueField: "id",
	  		textField: "name",
	  		multiple: false,
	  		editable: false, 
	  		method: "post",
	  	});
	    $("#add_studentList").combobox({
	  		url: "StudentServlet?method=StudentList&t="+new Date().getTime()+"&from=combox",
	  		onLoadSuccess: function(){
				var data = $(this).combobox("getData");
				$(this).combobox("setValue", data[0].id);
	  		}
	  	});
	    $("#edit_studentList").combobox({
	  		url: "StudentServlet?method=StudentList&t="+new Date().getTime()+"&from=combox",
	  		onLoadSuccess: function(){
				var data = $(this).combobox("getData");
				$(this).combobox("setValue", data[0].id);
	  		}
	  	});
	  	
	  	$("#search-btn").click(function(){
	  		$('#dataList').datagrid('load',{
	  			studentid: $("#studentList").combobox('getValue') == '' ? 0 : $("#studentList").combobox('getValue')
	  		});
	  	});
	    
	  	$("#clear-btn").click(function(){
	    	$('#dataList').datagrid("reload",{});
	    	$("#studentList").combobox('clear');
	    });
	});
	</script>
</head>
<body>
	<table id="dataList" cellspacing="0" cellpadding="0"> 
	    
	</table> 
	<div id="toolbar">
		<div style="float: left;"><a id="add" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">add</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>
		<c:if test="${userType == 2}">
		<div style="float: left;"><a id="edit" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true">update</a></div>
		</c:if>
		<c:if test="${userType == 1 || userType == 3}">
		<div style="float: left;"><a id="check" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true">review</a></div>
		</c:if>
		<div style="float: left; margin-right: 10px;"><a id="delete" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-some-delete',plain:true">delete</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>
		<div style="margin-top: 3px;">
			student：<input id="studentList" class="easyui-textbox" name="studentid" />
			<a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">search</a>
			<a id="clear-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">clear search</a>
		</div>
	</div>
	
	<div id="addDialog" style="padding: 10px">  
    	<form id="addForm" method="post">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td style="width:60px">student:</td>
	    			<td colspan="3">
	    				<input id="add_studentList" style="width: 300px; height: 30px;" class="easyui-textbox" name="studentid" data-options="required:true, missingMessage:'please select student info'" />
	    			</td>
	    		</tr>
	    		<tr>
	    			<td>Reason for leave:</td>
	    			<td>
	    				<textarea id="info" name="info" style="width: 300px; height: 160px;" class="easyui-textbox" data-options="multiline:true,required:true, missingMessage:'Reason for leave is not null'" ></textarea>
	    			</td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
	<div id="editDialog" style="padding: 10px">  
    	<form id="editForm" method="post">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td style="width:60px">student:</td>
	    			<td colspan="3">
	    				<input id="edit_studentList" style="width: 300px; height: 30px;" class="easyui-textbox" name="studentid" data-options="required:true, missingMessage:'please select student info'" />
	    			</td>
	    		</tr>
	    		<tr>
	    			<td>Reason for leave:</td>
	    			<td>
	    				<textarea id="edit_info" name="info" style="width: 300px; height: 160px;" class="easyui-textbox" data-options="multiline:true,required:true, missingMessage:'Reason for leave is not null'" ></textarea>
	    			</td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
	<div id="checkDialog" style="padding: 10px">  
    	<form id="editForm" method="post">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td style="width:60px">student:</td>
	    			<td colspan="3">
	    				<select id="check_statusList" style="width: 300px; height: 30px;" class="easyui-combobox" name="status" data-options="required:true, missingMessage:'Please select status'" >
	    					<option value="1">pass the review</option>
	    					<option value="-1">no pass the review</option>
	    				</select>
	    			</td>
	    		</tr>
	    		<tr>
	    			<td>Content of approval:</td>
	    			<td>
	    				<textarea id="check_remark" name="remark" style="width: 300px; height: 160px;" class="easyui-textbox" data-options="multiline:true" ></textarea>
	    			</td>
	    		</tr>
	    	</table>
	    </form>
	</div>
</body>
</html>