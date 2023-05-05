<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta charset="UTF-8">
	<title>Course selection list</title>
	<link rel="stylesheet" type="text/css" href="easyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="easyui/themes/icon.css">
	<link rel="stylesheet" type="text/css" href="easyui/css/demo.css">
	<script type="text/javascript" src="easyui/jquery.min.js"></script>
	<script type="text/javascript" src="easyui/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="easyui/js/validateExtends.js"></script>
	<script type="text/javascript">
	$(function() {	
	    $('#dataList').datagrid({ 
	        title:'List of course selection information', 
	        iconCls:'icon-more',
	        border: true, 
	        collapsible: false,
	        fit: true,
	        method: "post",
	        url:"SelectedCourseServlet?method=SelectedCourseList&t="+new Date().getTime(),
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
 		        {field:'studentId',title:'student',width:200,
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
 		       	{field:'courseId',title:'course',width:200,
 		        	formatter: function(value,row,index){
 						if (row.courseId){
 							var courseList = $("#courseList").combobox("getData");
 							for(var i=0;i<courseList.length;i++ ){
 								//console.log(clazzList[i]);
 								if(row.courseId == courseList[i].id)return courseList[i].name;
 							}
 							return row.courseId;
 						} else {
 							return 'not found';
 						}
 					}		
 		       	},
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
		  		
		  	});
	  		$("#courseList").combobox({
		  		width: "150",
		  		height: "25",
		  		valueField: "id",
		  		textField: "name",
		  		multiple: false, 
		  		editable: false, 
		  		method: "post",
		  		url: "CourseServlet?method=CourseList&t="+new Date().getTime()+"&from=combox",
		  		
		  	});
	  	}
		
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
	    
	    $("#edit").click(function(){
	    	table = $("#editTable");
	    	var selectRows = $("#dataList").datagrid("getSelections");
        	if(selectRows.length != 1){
            	$.messager.alert("Message reminder", "Select a piece of data to operate!", "warning");
            } else{
		    	$("#editDialog").dialog("open");
            }
	    });
	    
	    
	    $("#delete").click(function(){
	    	var selectRow = $("#dataList").datagrid("getSelected");
        	if(selectRow == null){
            	$.messager.alert("Message reminder", "Select data to delete!", "warning");
            } else{
            	var id = selectRow.id;
            	$.messager.confirm("Message reminder", "All data related to the course will be deleted. Confirm to continue？", function(r){
            		if(r){
            			$.ajax({
							type: "post",
							url: "SelectedCourseServlet?method=DeleteSelectedCourse",
							data: {id: id},
							success: function(msg){
								if(msg == "success"){
									$.messager.alert("Message reminder","Deleted successfully!","info");
									$("#dataList").datagrid("reload");
								}else if(msg == "not found"){
									$.messager.alert("Message reminder","There is no record of this course selection!","info");
								}else{
									$.messager.alert("Message reminder","Deletion failure!","warning");
									return;
								}
							}
						});
            		}
            	});
            }
	    });
	  	
	    $("#addDialog").dialog({
	    	title: "Add course selection information",
	    	width: 450,
	    	height: 200,
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
							$.messager.alert("Message reminder","Please check your info!","warning");
							return;
						} else{
							$.ajax({
								type: "post",
								url: "SelectedCourseServlet?method=AddSelectedCourse",
								data: $("#addForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("Message reminder","Course selection information added successfully!","info");
										$("#addDialog").dialog("close");
										$("#add_name").textbox('setValue', "");
										$('#dataList').datagrid("reload");
									} else if(msg == "courseFull"){
										$.messager.alert("Message reminder","The course is full and cannot be re-selected!","warning");
										return;
									} else if(msg == "courseSelected"){
										$.messager.alert("Message reminder","You have already taken this course. You cannot take it again!","warning");
										return;
									}else{
										$.messager.alert("Message reminder","An internal system error occurs. Please contact the administrator!","warning");
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
	  	
	  	$("#add_studentList, #add_courseList,#studentList,#courseList").combobox({
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
	  	
	    $("#add_courseList").combobox({
	  		url: "CourseServlet?method=CourseList&t="+new Date().getTime()+"&from=combox",
	  		onLoadSuccess: function(){
				var data = $(this).combobox("getData");
				$(this).combobox("setValue", data[0].id);
	  		}
	  	});
	  	
	  	$("#search-btn").click(function(){
	  		$('#dataList').datagrid('load',{
	  			studentid: $("#studentList").combobox('getValue') == '' ? 0 : $("#studentList").combobox('getValue'),
	  			courseid: $("#courseList").combobox('getValue') == '' ? 0 : $("#courseList").combobox('getValue')
	  		});
	  	});
	});
	</script>
</head>
<body>
	<!-- Data List -->
	<table id="dataList" cellspacing="0" cellpadding="0"> 
	    
	</table> 
	<div id="toolbar">
		<div style="float: left;"><a id="add" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">add</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>
		<div style="float: left; margin-right: 10px;"><a id="delete" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-some-delete',plain:true">withdrawal</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>
		<div style="margin-top: 3px;">
			student：<input id="studentList" class="easyui-textbox" name="studentList" />
			course：<input id="courseList" class="easyui-textbox" name="courseList" />
			<a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">search</a>
		</div>
	</div>
	
	<div id="addDialog" style="padding: 10px">  
    	<form id="addForm" method="post">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td style="width:40px">student:</td>
	    			<td colspan="3">
	    				<input id="add_studentList" style="width: 200px; height: 30px;" class="easyui-textbox" name="studentid" />
	    			</td>
	    			<td style="width:80px"></td>
	    		</tr>
	    		<tr>
	    			<td style="width:40px">course:</td>
	    			<td colspan="3">
	    				<input id="add_courseList" style="width: 200px; height: 30px;" class="easyui-textbox" name="courseid" />
	    			</td>
	    			<td style="width:80px"></td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
</body>
</html>