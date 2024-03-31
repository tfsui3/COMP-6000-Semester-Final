<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta charset="UTF-8">
	<title>List of grades</title>
	<link rel="stylesheet" type="text/css" href="easyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="easyui/themes/icon.css">
	<link rel="stylesheet" type="text/css" href="easyui/css/demo.css">
	<script type="text/javascript" src="easyui/jquery.min.js"></script>
	<script type="text/javascript" src="easyui/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="easyui/js/validateExtends.js"></script>
	<script type="text/javascript">
	$(function() {	
	    $('#dataList').datagrid({ 
	        title:'Grade information list', 
	        iconCls:'icon-more',
	        border: true, 
	        collapsible: false,
	        fit: true,
	        method: "post",
	        url:"ScoreServlet?method=ScoreList&t="+new Date().getTime(),
	        idField:'id', 
	        singleSelect: true,
	        pagination: true,
	        rownumbers: true,
	        sortName:'id',
	        sortOrder:'DESC', 
	        remoteSort: false,
	        columns: [[  
				{field:'chk',checkbox: true,width:50},
 		        {field:'id',title:'ID',width:50},    
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
 		       {field:'score',title:'achievement',width:200},
 		       {field:'remark',title:'remarks',width:200}
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
	        afterPageText: 'page   total{pages} page', 
	        displayMsg: 'Current display {from} - {to} Bar record   tatal {total}  Bar record', 
	    });
	   	
	    $("#add").click(function(){
	    	$("#addDialog").dialog("open");
	    });
	    
	    $("#import").click(function(){
	    	$("#importDialog").dialog("open");
	    });
	    
	    $("#edit").click(function(){
	    	table = $("#editTable");
	    	var selectRows = $("#dataList").datagrid("getSelections");
        	if(selectRows.length != 1){
            	$.messager.alert("Message reminder", "Select a piece of data to operate!", "warning");
            } else{
            	$("#edit_id").val(selectRows[0].id);
		    	$("#editDialog").dialog("open");
            }
	    });
	    
	    
	    $("#delete").click(function(){
	    	var selectRow = $("#dataList").datagrid("getSelected");
        	if(selectRow == null){
            	$.messager.alert("Message reminder", "Select data to delete!", "warning");
            } else{
            	var id = selectRow.id;
            	$.messager.confirm("Message reminder", "Are you sure you want to delete the grade? Go ahead？", function(r){
            		if(r){
            			$.ajax({
							type: "post",
							url: "ScoreServlet?method=DeleteScore",
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
	    	title: "Add grade information",
	    	width: 450,
	    	height: 450,
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
							$.messager.alert("Message reminde","Please check the data you entered!","warning");
							return;
						} else{
							$.ajax({
								type: "post",
								url: "ScoreServlet?method=AddScore",
								data: $("#addForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("Message reminde","Course selection information added successfully!","info");
										$("#addDialog").dialog("close");
										$("#add_remark").textbox('setValue', "");
										$('#dataList').datagrid("reload");
									} else if(msg == "added"){
										$.messager.alert("Message reminde","The score of this course has been recorded and cannot be recorded again!","warning");
										return;
									} else{
										$.messager.alert("Message reminde","An internal system error occurs. Please contact the administrator!","warning");
										return;
									}
								}
							});
						}
					}
				},
				{
					text:'reset*',
					plain: true,
					iconCls:'icon-book-reset',
					handler:function(){
						$("#add_remark").textbox('setValue', "");
					}
				},
			]
	    });
	  	
	    $("#editDialog").dialog({
	    	title: "Modify grade information",
	    	width: 450,
	    	height: 450,
	    	iconCls: "icon-edit",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	    		{
					text:'update',
					plain: true,
					iconCls:'icon-book-edit',
					handler:function(){
						var validate = $("#editForm").form("validate");
						if(!validate){
							$.messager.alert("Message reminder","Please check the data you entered!","warning");
							return;
						} else{
							$.ajax({
								type: "post",
								url: "ScoreServlet?method=EditScore",
								data: $("#editForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("Message reminder","Course selection information added successfully!","info");
										$("#editDialog").dialog("close");
										$("#edit_remark").textbox('setValue', "");
										$('#dataList').datagrid("reload");
									} else if(msg == "added"){
										$.messager.alert("Message reminder","The score of this course has been recorded and cannot be recorded again!","warning");
										return;
									} else{
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
						$("#edit_remark").textbox('setValue', "");
					}
				},
			],
			onBeforeOpen: function(){
				var selectRow = $("#dataList").datagrid("getSelected");
				$("#edit_studentList").combobox('setValue', selectRow.studentId);
				$("#edit_score").numberbox('setValue', selectRow.score);
				$("#edit_remark").textbox('setValue', selectRow.remark);
				setTimeout(function(){
					$("#edit_courseList").combobox('setValue', selectRow.courseId);
				}, 100);
				
			}
	    });
	  	
	    $("#importDialog").dialog({
	    	title: "Import grade information",
	    	width: 450,
	    	height: 150,
	    	iconCls: "icon-add",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	    		{
					text:'Confirm import',
					plain: true,
					iconCls:'icon-book-add',
					handler:function(){
						var validate = $("#importForm").form("validate");
						if(!validate){
							$.messager.alert("Message reminder","Please select file!","warning");
							return;
						} else{
							importScore();
							$("#importDialog").dialog("close");
						}
					}
				}
			]
	    });
	  
	  	$("#add_studentList, #add_courseList,#studentList,#courseList,#edit_studentList, #edit_courseList").combobox({
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
				getStudentSelectedCourseList(data[0].id);
	  		},
	  		onChange:function(id,o){
	  			getStudentSelectedCourseList(id);
	  		}
	  	});
	  
	    
	    function getStudentSelectedCourseList(studentId){
			    $("#add_courseList").combobox({
			  		url: "AttendanceServlet?method=getStudentSelectedCourseList&t="+new Date().getTime()+"&student_id="+studentId,
			  		onLoadSuccess: function(){
						var data = $(this).combobox("getData");
						$(this).combobox("setValue", data[0].id);
			  		}
			  	});
		  	}	
	  
	    $("#edit_studentList").combobox({
	  		url: "StudentServlet?method=StudentList&t="+new Date().getTime()+"&from=combox",
	  		onLoadSuccess: function(){
				var data = $(this).combobox("getData");
				$(this).combobox("setValue", data[0].id);
				getEditStudentSelectedCourseList(data[0].id);
	  		},
	  		onChange:function(id,o){
	  			getEditStudentSelectedCourseList(id);
	  		}
	  	});
	    function getEditStudentSelectedCourseList(studentId){
			    $("#edit_courseList").combobox({
			  		url: "AttendanceServlet?method=getStudentSelectedCourseList&t="+new Date().getTime()+"&student_id="+studentId,
			  		onLoadSuccess: function(){
						var data = $(this).combobox("getData");
						$(this).combobox("setValue", data[0].id);
			  		}
			  	});
		  	}
	  
	  	$("#search-btn").click(function(){
	  		$('#dataList').datagrid('load',{
	  			studentid: $("#studentList").combobox('getValue') == '' ? 0 : $("#studentList").combobox('getValue'),
	  			courseid: $("#courseList").combobox('getValue') == '' ? 0 : $("#courseList").combobox('getValue')
	  		});
	  	});
	    
	  	$("#export").click(function(){
	  		studentid = $("#studentList").combobox('getValue') == '' ? 0 : $("#studentList").combobox('getValue');
	  		courseid = $("#courseList").combobox('getValue') == '' ? 0 : $("#courseList").combobox('getValue');
	  		url = 'ScoreServlet?method=ExportScoreList&studentid='+studentid+"&courseid="+courseid;
	  		window.location.href = url;
	  	});
	    
	  	$("#clear-btn").click(function(){
	    	$('#dataList').datagrid("reload",{});
	    	$("#studentList").combobox('clear');
	    	$("#courseList").combobox('clear');
	    });
	    
	  	function importScore(){
			$("#importForm").submit();
			$.messager.progress({text:'Being uploaded and imported...'});
			var interval = setInterval(function(){
				var message =  $(window.frames["import_target"].document).find("#message").text();
				if(message != null && message != ''){
					$.messager.progress('close');
					$.messager.alert("Message reminder",message,"info");
					$('#dataList').datagrid("reload");
					clearInterval(interval);
				}
			}, 1000)
		}
	});
	</script>
</head>
<body>
	<table id="dataList" cellspacing="0" cellpadding="0"> 
	    
	</table> 
	<div id="toolbar">
		<c:if test="${userType != 2}">
		<div style="float: left;"><a id="add" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">add</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>
		<div style="float: left;"><a id="import" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">import</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>
		<div style="float: left;"><a id="export" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">export</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>
		<div style="float: left;"><a id="edit" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true">update</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>
		<div style="float: left; margin-right: 10px;"><a id="delete" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-some-delete',plain:true">delete</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>
		</c:if>
		<div style="margin-top: 3px;">
			studnet：<input id="studentList" class="easyui-textbox" name="studentList" />
			course：<input id="courseList" class="easyui-textbox" name="courseList" />
			<a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">search</a>
			<a id="clear-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">Clear search</a>
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
	    				<input id="add_courseList" style="width: 200px; height: 30px;" class="easyui-textbox" name="courseid" data-options="required:true, missingMessage:'Please select the course'" />
	    			</td>
	    			<td style="width:80px"></td>
	    		</tr>
	    		
	    		<tr>
	    			<td style="width:40px">grade:</td>
	    			<td colspan="3">
	    				<input id="add_score" style="width: 200px; height: 30px;" class="easyui-numberbox" data-options="required:true,min:0,precision:2, missingMessage:'Please fill in the correct grades'" name="score" />
	    			</td>
	    			<td style="width:80px"></td>
	    		</tr>
	    		
	    		<tr>
	    			<td>remark:</td>
	    			<td>
	    				<textarea id="add_remark" name="remark" style="width: 300px; height: 160px;" class="easyui-textbox" data-options="multiline:true" ></textarea>
	    			</td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
	<div id="editDialog" style="padding: 10px">  
    	<form id="editForm" method="post">
	    	
	    	<input type="hidden" id="edit_id" name="id">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td style="width:40px">student:</td>
	    			<td colspan="3">
	    				<input id="edit_studentList" style="width: 200px; height: 30px;" class="easyui-textbox" name="studentid" />
	    			</td>
	    			<td style="width:80px"></td>
	    		</tr>
	    		<tr>
	    			<td style="width:40px">course:</td>
	    			<td colspan="3">
	    				<input id="edit_courseList" style="width: 200px; height: 30px;" class="easyui-textbox" name="courseid" data-options="required:true, missingMessage:'Please select the course'" />
	    			</td>
	    			<td style="width:80px"></td>
	    		</tr>
	    		
	    		<tr>
	    			<td style="width:40px">grade:</td>
	    			<td colspan="3">
	    				<input id="edit_score" style="width: 200px; height: 30px;" class="easyui-numberbox" data-options="required:true,min:0,precision:2, missingMessage:'Please fill in the correct grades'" name="score" />
	    			</td>
	    			<td style="width:80px"></td>
	    		</tr>
	    		
	    		<tr>
	    			<td>remark:</td>
	    			<td>
	    				<textarea id="edit_remark" name="remark" style="width: 300px; height: 160px;" class="easyui-textbox" data-options="multiline:true" ></textarea>
	    			</td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
	<div id="importDialog" style="padding: 10px">  
    	<form id="importForm" method="post" enctype="multipart/form-data" action="ScoreServlet?method=ImportScore" target="import_target">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td>Please select file:</td>
	    			<td>
	    				<input class="easyui-filebox" name="importScore" data-options="required:true,min:0,precision:2, missingMessage:'Please select file',prompt:'Select file'" style="width:200px;">
	    			</td>
	    		</tr>
	    		
	    	</table>
	    </form>
	</div>
	<iframe id="import_target" name="import_target"></iframe>	
</body>
</html>