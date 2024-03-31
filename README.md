# COMP-6000-Semester-Final

The original intention behind this project design is that although Canvas is powerful and comprehensive, I believe that there are some shortcomings in certain features, such as the handling of student leave requests and attendance scores. Also, it's overly functional and not precise enough.

# System Architecture

The student information management system is developed using the servlet+jsp framework, which follows the standard MVC pattern, dividing the entire system into four layers: View layer, Controller layer, Service layer, and DAO layer. Among them, data retrieval and display are done in the View layer, business object management is implemented in the Controller layer using servlets, and JSP is used as the persistence engine for data objects. The entire system structure and operation process is shown in Figure:

![image](https://github.com/tfsui3/COMP-6000-Semester-Final/assets/46233292/c4eb4df0-6be4-4db2-9b72-cc9bb27e472f)

View layer：It is closely combined with the Controller layer and needs to work together for front-end JSP page presentation.
Controller layer：The controller imports the Service layer because the methods in Service layer are the ones we use. The controller receives parameters passed from the front-end to perform operations and returns a specified path or data table.
	Service layer：Regarding database operations, they are not directly handled with the database. There are interfaces and implementation methods for the interfaces. In the implementation methods of the interface, the Dao layer needs to be imported. The Dao layer directly interacts with the database and it is also an interface that only has method names. The specific implementation is in the mapper.xml file. The Service layer provides methods for our use.
	Dao layer: Responsible for the operations of adding, deleting, modifying, and querying data to the database.
	Persistence Layer: JSP here is used to persist entity objects into the database, eliminating the need for complex JDBC and SQL statements. In the Dao layer, JSP syntax can be used directly to execute the desired SQL.
 
# Design of System Functional Modules.

The student information management system has a relatively high degree of comprehensiveness and complexity. It can make full use of existing software for system design and planning. Building a complete and mature student information management system involves the front-end pages, processing programs, MySQL back-end database system, etc. The processing program is actually responsible for processing user-submitted forms and related operations. Information stored in the back-end database includes grade data, student data, etc.
