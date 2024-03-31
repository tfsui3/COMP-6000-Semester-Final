package com.ischoolbar.programmer.servlet;

import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileUploadException;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.ischoolbar.programmer.dao.CourseDao;
import com.ischoolbar.programmer.dao.ScoreDao;
import com.ischoolbar.programmer.dao.SelectedCourseDao;
import com.ischoolbar.programmer.dao.StudentDao;
import com.ischoolbar.programmer.dao.TeacherDao;
import com.ischoolbar.programmer.model.Course;
import com.ischoolbar.programmer.model.Page;
import com.ischoolbar.programmer.model.Score;
import com.ischoolbar.programmer.model.SelectedCourse;
import com.ischoolbar.programmer.model.Student;
import com.ischoolbar.programmer.model.Teacher;
import com.lizhou.exception.FileFormatException;
import com.lizhou.exception.NullFileException;
import com.lizhou.exception.ProtocolException;
import com.lizhou.exception.SizeException;
import com.lizhou.fileload.FileUpload;

public class ScoreServlet extends HttpServlet {


	private static final long serialVersionUID = -153736421631912372L;
	
	

	public void doGet(HttpServletRequest request,HttpServletResponse response) throws IOException{
		doPost(request, response);
	}
	public void doPost(HttpServletRequest request,HttpServletResponse response) throws IOException{
		String method = request.getParameter("method");
		if("toScoreListView".equals(method)){
			try {
				request.getRequestDispatcher("view/scoreList.jsp").forward(request, response);
			} catch (ServletException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}else if("AddScore".equals(method)){
			addScore(request,response);
		}else if("ScoreList".equals(method)){
			getScoreList(request,response);
		}else if("EditScore".equals(method)){
			editScore(request,response);
		}else if("DeleteScore".equals(method)){
			deleteScore(request,response);
		}else if("ImportScore".equals(method)){
			importScore(request,response);
		}else if("ExportScoreList".equals(method)){
			exportScore(request,response);
		}else if("toScoreStatsView".equals(method)){
			try {
				request.getRequestDispatcher("view/scoreStats.jsp").forward(request, response);
			} catch (ServletException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}else if("getStatsList".equals(method)){
			getStatsList(request,response);
		}
	}
	private void getStatsList(HttpServletRequest request,
			HttpServletResponse response) {
		// TODO Auto-generated method stub
		int courseId = request.getParameter("courseid") == null ? 0 : Integer.parseInt(request.getParameter("courseid").toString());
		String searchType = request.getParameter("searchType");
		response.setCharacterEncoding("UTF-8");
		if(courseId == 0){
			try {
				response.getWriter().write("error");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			return;
		}
		ScoreDao scoreDao = new ScoreDao();
		Score score = new Score();
		score.setCourseId(courseId);
		if("avg".equals(searchType)){
			Map<String, Object> avgStats = scoreDao.getAvgStats(score);
			List<Double> scoreList = new ArrayList<Double>();
			scoreList.add(Double.parseDouble(avgStats.get("max_score").toString()));
			scoreList.add(Double.parseDouble(avgStats.get("min_score").toString()));
			scoreList.add(Double.parseDouble(avgStats.get("avg_score").toString()));
			List<String> avgStringList = new ArrayList<String>();
			avgStringList.add("��߷�");
			avgStringList.add("��ͷ�");
			avgStringList.add("ƽ����");
			Map<String, Object> retMap = new HashMap<String, Object>();
			retMap.put("courseName", avgStats.get("courseName").toString());
			retMap.put("scoreList", scoreList);
			retMap.put("avgList", avgStringList);
			retMap.put("type", "suceess");
			try {
				response.getWriter().write(JSONObject.fromObject(retMap).toString());
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			return;
		}
		List<Map<String, Object>> scoreList = scoreDao.getScoreList(score);
		
		List<Integer> numberList = new ArrayList<Integer>();
		numberList.add(0);
		numberList.add(0);
		numberList.add(0);
		numberList.add(0);
		numberList.add(0);
		List<String> rangeStringList = new ArrayList<String>();
		rangeStringList.add("60������");
		rangeStringList.add("60~70��");
		rangeStringList.add("70~80��");
		rangeStringList.add("80~90��");
		rangeStringList.add("90~100��");
		String courseName = "";
		for(Map<String, Object> entry:scoreList){
			courseName = entry.get("courseName").toString();
			double scoreValue = Double.parseDouble(entry.get("score").toString());
			if(scoreValue < 60){
				numberList.set(0, numberList.get(0)+1);
				continue;
			}
			if(scoreValue <= 70 && scoreValue >= 60){
				numberList.set(1, numberList.get(1)+1);
				continue;
			}
			if(scoreValue <= 80 && scoreValue > 70){
				numberList.set(2, numberList.get(2)+1);
				continue;
			}
			if(scoreValue <= 90 && scoreValue > 80){
				numberList.set(3, numberList.get(3)+1);
				continue;
			}
			if(scoreValue <= 100 && scoreValue > 90){
				numberList.set(4, numberList.get(4)+1);
				continue;
			}
		}
		Map<String, Object> retMap = new HashMap<String, Object>();
		retMap.put("courseName", courseName);
		retMap.put("numberList", numberList);
		retMap.put("rangeList", rangeStringList);
		retMap.put("type", "suceess");
		try {
			response.getWriter().write(JSONObject.fromObject(retMap).toString());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	private void exportScore(HttpServletRequest request,
			HttpServletResponse response) {
		// TODO Auto-generated method stub
		int studentId = request.getParameter("studentid") == null ? 0 : Integer.parseInt(request.getParameter("studentid").toString());
		int courseId = request.getParameter("courseid") == null ? 0 : Integer.parseInt(request.getParameter("courseid").toString());
		//��ȡ��ǰ��¼�û�����
		int userType = Integer.parseInt(request.getSession().getAttribute("userType").toString());
		if(userType == 2){
			//�����ѧ����ֻ�ܲ鿴�Լ�����Ϣ
			Student currentUser = (Student)request.getSession().getAttribute("user");
			studentId = currentUser.getId();
		}
		Score score = new Score();
		score.setStudentId(studentId);
		score.setCourseId(courseId);
		try {
			response.setHeader("Content-Disposition", "attachment;filename="+URLEncoder.encode("score_list_sid_"+studentId+"_cid_"+courseId+".xls", "UTF-8"));
			response.setHeader("Connection", "close");
			response.setHeader("Content-Type", "application/octet-stream");
			ServletOutputStream outputStream = response.getOutputStream();
			ScoreDao scoreDao = new ScoreDao();
			List<Map<String, Object>> scoreList = scoreDao.getScoreList(score);
			scoreDao.closeCon();
			HSSFWorkbook hssfWorkbook = new HSSFWorkbook();
			HSSFSheet createSheet = hssfWorkbook.createSheet("�ɼ��б�");
			HSSFRow createRow = createSheet.createRow(0);
			createRow.createCell(0).setCellValue("ѧ��");
			createRow.createCell(1).setCellValue("�γ�");
			createRow.createCell(2).setCellValue("�ɼ�");
			createRow.createCell(3).setCellValue("��ע");
			//ʵ�ֽ�����װ�뵽excel�ļ���
			int row = 1;
			for(Map<String, Object> entry:scoreList){
				createRow = createSheet.createRow(row++);
				createRow.createCell(0).setCellValue(entry.get("studentName").toString());
				createRow.createCell(1).setCellValue(entry.get("courseName").toString());
				createRow.createCell(2).setCellValue(new Double(entry.get("score")+""));
				createRow.createCell(3).setCellValue(entry.get("remark")+"");
			}
			hssfWorkbook.write(outputStream);
			outputStream.flush();
			outputStream.close();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	private void importScore(HttpServletRequest request,
			HttpServletResponse response) {
		// TODO Auto-generated method stub
		FileUpload fileUpload = new FileUpload(request);
		fileUpload.setFileFormat("xls");
		fileUpload.setFileFormat("xlsx");
		fileUpload.setFileSize(2048);
		response.setCharacterEncoding("UTF-8");
		try {
			InputStream uploadInputStream = fileUpload.getUploadInputStream();
			HSSFWorkbook hssfWorkbook = new HSSFWorkbook(uploadInputStream);
			HSSFSheet sheetAt = hssfWorkbook.getSheetAt(0);
			int count = 0;
			String errorMsg = "";
			StudentDao studentDao = new StudentDao();
			CourseDao courseDao = new CourseDao();
			ScoreDao scoreDao = new ScoreDao();
			SelectedCourseDao selectedCourseDao = new SelectedCourseDao();
			for(int rowNum = 1; rowNum <= sheetAt.getLastRowNum(); rowNum++){
				HSSFRow row = sheetAt.getRow(rowNum);
				HSSFCell cell = row.getCell(0);
				//��ȡ��0�У�ѧ��id
				if(cell == null){
					errorMsg += "��" + rowNum + "��ѧ��idȱʧ��\n";
					continue;
				}
				if(cell.getCellType() != cell.CELL_TYPE_NUMERIC){
					errorMsg += "��" + rowNum + "��ѧ��id���Ͳ���������\n";
					continue;
				}
				int studentId = new Double(cell.getNumericCellValue()).intValue();
				//��ȡ��1�У��γ�id
				cell = row.getCell(1);
				if(cell == null){
					errorMsg += "��" + rowNum + "�пγ�idȱʧ��\n";
					continue;
				}
				if(cell.getCellType() != cell.CELL_TYPE_NUMERIC){
					errorMsg += "��" + rowNum + "�пγ�id����������\n";
					continue;
				}
				int courseId = new Double(cell.getNumericCellValue()).intValue();
				//��ȡ��2�У��ɼ�
				cell = row.getCell(2);
				if(cell == null){
					errorMsg += "��" + rowNum + "�гɼ�ȱʧ��\n";
					continue;
				}
				if(cell.getCellType() != cell.CELL_TYPE_NUMERIC){
					errorMsg += "��" + rowNum + "�гɼ����Ͳ������֣�\n";
					continue;
				}
				double scoreValue = cell.getNumericCellValue();
				//��ȡ��3�У���ע
				cell = row.getCell(3);
				String remark = null;
				if(cell != null){
					remark = cell.getStringCellValue();
				}
				Student student = studentDao.getStudent(studentId);
				if(student == null){
					errorMsg += "��" + rowNum + "��ѧ��id�����ڣ�\n";
					continue;
				}
				Course course = courseDao.getCourse(courseId);
				if(course == null){
					errorMsg += "��" + rowNum + "�пγ�id�����ڣ�\n";
					continue;
				}
				if(!selectedCourseDao.isSelected(studentId, courseId)){
					errorMsg += "��" + rowNum + "�пγ̸�ͬѧδѡ�����Ϸ���\n";
					continue;
				}
				if(scoreDao.isAdd(studentId, courseId)){
					errorMsg += "��" + rowNum + "�гɼ��Ѿ�����ӣ������ظ���ӣ�\n";
					continue;
				}
				Score score = new Score();
				score.setCourseId(courseId);
				score.setRemark(remark);
				score.setScore(scoreValue);
				score.setStudentId(studentId);
				if(scoreDao.addScore(score)){
					count++;
				}
			}
			errorMsg += "�ɹ�¼��" + count + "���ɼ���Ϣ��";
			studentDao.closeCon();
			courseDao.closeCon();
			selectedCourseDao.closeCon();
			scoreDao.closeCon();
			try {
				response.getWriter().write("<div id='message'>"+errorMsg+"</div>");
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			
		} catch (ProtocolException e) {
			// TODO Auto-generated catch block
			try {
				response.getWriter().write("<div id='message'>�ϴ�Э�����</div>");
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			e.printStackTrace();
		}catch (NullFileException e1) {
			// TODO: handle exception
			try {
				response.getWriter().write("<div id='message'>�ϴ����ļ�Ϊ��!</div>");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			e1.printStackTrace();
		}
		catch (SizeException e2) {
			// TODO: handle exception
			try {
				response.getWriter().write("<div id='message'>�ϴ��ļ���С���ܳ���"+fileUpload.getFileSize()+"��</div>");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			e2.printStackTrace();
		}
		catch (IOException e3) {
			// TODO: handle exception
			try {
				response.getWriter().write("<div id='message'>��ȡ�ļ�����</div>");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			e3.printStackTrace();
		}
		catch (FileFormatException e4) {
			// TODO: handle exception
			try {
				response.getWriter().write("<div id='message'>�ϴ��ļ���ʽ����ȷ�����ϴ� "+fileUpload.getFileFormat()+" ��ʽ���ļ���</div>");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			e4.printStackTrace();
		}
		catch (FileUploadException e5) {
			// TODO: handle exception
			try {
				response.getWriter().write("<div id='message'>�ϴ��ļ�ʧ�ܣ�</div>");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			e5.printStackTrace();
		}
	}
	private void deleteScore(HttpServletRequest request,
			HttpServletResponse response) {
		// TODO Auto-generated method stub
		int id = Integer.parseInt(request.getParameter("id"));
		ScoreDao scoreDao = new ScoreDao();
		String msg = "success";
		if(!scoreDao.deleteScore(id)){
			msg = "error";
		}
		scoreDao.closeCon();
		try {
			response.getWriter().write(msg);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	private void editScore(HttpServletRequest request,
			HttpServletResponse response) {
		// TODO Auto-generated method stub
		int id = Integer.parseInt(request.getParameter("id"));
		int studentId = request.getParameter("studentid") == null ? 0 : Integer.parseInt(request.getParameter("studentid").toString());
		int courseId = request.getParameter("courseid") == null ? 0 : Integer.parseInt(request.getParameter("courseid").toString());
		Double scoreNum = Double.parseDouble(request.getParameter("score"));
		String remark = request.getParameter("remark");
		Score score = new Score();
		score.setId(id);
		score.setCourseId(courseId);
		score.setStudentId(studentId);
		score.setScore(scoreNum);
		score.setRemark(remark);
		ScoreDao scoreDao = new ScoreDao();
		String ret = "success";
		if(!scoreDao.editScore(score)){
			ret = "error";
		}
		try {
			response.getWriter().write(ret);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	private void getScoreList(HttpServletRequest request,
			HttpServletResponse response) {
		// TODO Auto-generated method stub
		int studentId = request.getParameter("studentid") == null ? 0 : Integer.parseInt(request.getParameter("studentid").toString());
		int courseId = request.getParameter("courseid") == null ? 0 : Integer.parseInt(request.getParameter("courseid").toString());
		Integer currentPage = request.getParameter("page") == null ? 1 : Integer.parseInt(request.getParameter("page"));
		Integer pageSize = request.getParameter("rows") == null ? 999 : Integer.parseInt(request.getParameter("rows"));
		Score score = new Score();
		//��ȡ��ǰ��¼�û�����
		int userType = Integer.parseInt(request.getSession().getAttribute("userType").toString());
		if(userType == 2){
			//�����ѧ����ֻ�ܲ鿴�Լ�����Ϣ
			Student currentUser = (Student)request.getSession().getAttribute("user");
			studentId = currentUser.getId();
		}
		score.setCourseId(courseId);
		score.setStudentId(studentId);
		ScoreDao scoreDao = new ScoreDao();
		List<Score> courseList = scoreDao.getScoreList(score, new Page(currentPage, pageSize));
		int total = scoreDao.getScoreListTotal(score);
		scoreDao.closeCon();
		response.setCharacterEncoding("UTF-8");
		Map<String, Object> ret = new HashMap<String, Object>();
		ret.put("total", total);
		ret.put("rows", courseList);
		try {
			String from = request.getParameter("from");
			if("combox".equals(from)){
				response.getWriter().write(JSONArray.fromObject(courseList).toString());
			}else{
				response.getWriter().write(JSONObject.fromObject(ret).toString());
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	private void addScore(HttpServletRequest request,
			HttpServletResponse response) {
		// TODO Auto-generated method stub
		int studentId = request.getParameter("studentid") == null ? 0 : Integer.parseInt(request.getParameter("studentid").toString());
		int courseId = request.getParameter("courseid") == null ? 0 : Integer.parseInt(request.getParameter("courseid").toString());
		Double scoreNum = Double.parseDouble(request.getParameter("score"));
		String remark = request.getParameter("remark");
		Score score = new Score();
		score.setCourseId(courseId);
		score.setStudentId(studentId);
		score.setScore(scoreNum);
		score.setRemark(remark);
		ScoreDao scoreDao = new ScoreDao();
		if(scoreDao.isAdd(studentId, courseId)){
			try {
				response.getWriter().write("added");
				scoreDao.closeCon();
				return;
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		String ret = "success";
		if(!scoreDao.addScore(score)){
			ret = "error";
		}
		try {
			response.getWriter().write(ret);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
