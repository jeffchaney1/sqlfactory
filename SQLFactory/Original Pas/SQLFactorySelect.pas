{******************************************************************************
  Implementation of the SQLFactory for creating SELECT statements

  @author Jeff Chaney
  @author Guardian Industries, Inc., Auburn Hills, MI
  @author Last Changed By: $Author: jchaney $ $Date: 2014/08/15 22:25:45 $
  @group Shared.SQLFactory
  @version $Id: SQLFactorySelect.pas,v 1.28 2014/08/15 22:25:45 jchaney Exp $
  @version
******************************************************************************}

unit SQLFactorySelect;

interface

uses UnitVersion, Classes, StringBuffer, TypedList, SysUtils, ADODB, PRADODB, SQLFactoryBase, Dialogs;

{$TYPEINFO ON}
type
  TSQLSelectFactory = class;

  {******************************************************************************
    Definition of the source of a SELECT statement
    &nbsp;
    This will most likely be a Table but could also be another SELECT.
  ******************************************************************************}
  TFromTable = class(TTable)
  private
//    fOwner : TPersistent;
    fSubSelect : TSQLSelectFactory;
    fHint : WideString;
  protected
    {******************************************************************************
      Getter for SubSelect property
      @group Getters
    ******************************************************************************}
    function GetSubSelect : TSQLSelectFactory; virtual;
    function GetIsSubSelect : Boolean; virtual;

    {******************************************************************************
      Setter for SubSelect property
      @group Setters
    ******************************************************************************}
    procedure SetSubSelect(const Value : TSQLSelectFactory); virtual;
    {******************************************************************************
      Override of the Setter for TableSchema property
      &nbsp;
      This version clears the subselect when the TableSchema is set.
      @group Setters
    ******************************************************************************}
    procedure SetTableSchema(const Value : WideString); override;
    {******************************************************************************
      Override of the Setter for TableName property
      &nbsp;
      This version clears the subselect when the TableSchema is set.
      @group Setters
    ******************************************************************************}
    procedure SetTableName(const Value : WideString); override;

    {******************************************************************************
      Getter for the Table Hint property
    ******************************************************************************}
    function Get_Hint : WideString; virtual;
    {******************************************************************************
      Setter for the Table Hint property
    ******************************************************************************}
    procedure Set_Hint(const Value : WideString); virtual;

//    function GetOwner : TPersistent; override;
    {******************************************************************************
      Called by BuildSQL to add source of the FROM clause
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param sql The TWideStringBuffer containing the sql being built
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildFromSource(sql : TWideStringBuffer;
                  parameters : TParameterList; const indent : WideString);

    {******************************************************************************
      Called by BuildSQL to add source of the FROM clause when it is a TableName
      &nbsp;
      This member was overridden to implement the table hint functionality
      @param sql The TWideStringBuffer containing the sql being built
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildFullTableIdentifier(sql: TWideStringBuffer; const indent : WideString);

    {******************************************************************************
      Called by BuildSQL to add source of the FROM clause when it is a SubSelect
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param sql The TWideStringBuffer containing the sql being built
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildSubSelect(sql : TWideStringBuffer;
                  parameters : TParameterList; const indent : WideString);


    {******************************************************************************
      Called by GetSubSelect to create a subselect when none has been assigned
      &nbsp;
      This member was added so decendants could inherit functionality of the
      FromTable without calling the inherited GetSubSelect
      @return A newly created subselect
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    function InternalCreateSubSelect : TSQLSelectFactory; virtual;
  public
//    constructor Create(AOwner : TPersistent); reintroduce;
    {******************************************************************************
      Destructor
      @group Constructors
    ******************************************************************************}
    destructor Destroy; override;

    {******************************************************************************
      TFromTable implementation of ISQLElement buildSQL() workhorse method.
      @param sql The TWideStringBuffer that is being used to accumulate the SQL
        command.
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The string prefix to be appended to front of each line
        of the SQL command.  This is really only to make the final command
        look pretty.  By default the top level starts with an empty string
        and it is up to the buildSQL() implementations to append STD_INDENT
        to the indent it was given for each lower level SQL Element.
      @see ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql: TWideStringBuffer; parameters: TParameterList; const indent : WideString = ''); override;

    procedure Assign(Source : TPersistent); override;
  published
    {******************************************************************************
      If assigned this will be used as the source (FROM) of the SELECT statement.
    ******************************************************************************}
    property SubSelect : TSQLSelectFactory read GetSubSelect Write SetSubSelect;
    property IsSubSelect : Boolean read GetIsSubSelect;
    property Hint : WideString read Get_Hint write Set_Hint;
  end;

  {******************************************************************************
    A column to be read in the SELECT statment
  ******************************************************************************}
  TSelectColumn = class(TColumn)
  private
    fColumnAlias : WideString;
    fIsNullDefault : WideString;
  protected
    {******************************************************************************
      Getter for ColumnAlias property
      @group Getters
    ******************************************************************************}
    function GetColumnAlias : WideString;
    {******************************************************************************
      Setter for ColumnAlias property
      @group Setters
    ******************************************************************************}
    procedure SetColumnAlias(const Value : WideString);
    {******************************************************************************
      Getter for IsNullDefault property
      @group Getters
    ******************************************************************************}
    function GetIsNullDefault: WideString;
    {******************************************************************************
      Setter for IsNullDefault property
      @group Setters
    ******************************************************************************}
    procedure SetIsNullDefault(const Value: WideString);
  public
//    constructor Create(columnExpression : WideString); overload; override;
//    constructor Create(columnExpression, columnAlias : WideString); overload; override;
//    constructor Create(tableAlias, columnExpression, columnAlias : WideString); overload;

    {******************************************************************************
      TSelectColumn implementation of ISQLElement buildSQL() workhorse method.
      @param sql The TWideStringBuffer that is being used to accumulate the SQL
        command.
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The string prefix to be appended to front of each line
        of the SQL command.  This is really only to make the final command
        look pretty.  By default the top level starts with an empty string
        and it is up to the buildSQL() implementations to append STD_INDENT
        to the indent it was given for each lower level SQL Element.
      @see ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); override;

    {******************************************************************************
      Matches on Column Alias
      @param Str The string to be compared to.
      @return True if string matches the Column Alias of this object.
    ******************************************************************************}
    function Match(const Str : WideString) : Boolean; override;


    procedure Assign(Source : TPersistent); override;
  published
    {******************************************************************************
      Defined in TTable. Moved to published here.
    ******************************************************************************}
    property TableName;
    {******************************************************************************
      Defined in TTable. Moved to published here.
    ******************************************************************************}
    property ColumnName;
    {******************************************************************************
      The colums alias name
    ******************************************************************************}
    property ColumnAlias : WideString read GetColumnAlias write SetColumnAlias;

    {******************************************************************************
      Value to be substituted if the column returns a NULL value
    ******************************************************************************}
    property IsNullDefault : WideString read GetIsNullDefault write SetIsNullDefault;
  end;

  {******************************************************************************
    The list of Columns in query.
  ******************************************************************************}
  TSelectColumnList = class(TCustomColumnList)
  protected
    {******************************************************************************
      Getter for Column property
      @param Key Can be either the Column alias to be found or the Integer Index
        of the Column in the list.
      @group Getters
    ******************************************************************************}
    function GetColumn(Key : Variant) : TSelectColumn;
  public
    {******************************************************************************
      Constructor
      @param AOwner (Optional:nil) The object that will control the life of this
        List.
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TPersistent = nil);

    {******************************************************************************
      Add a column to the list
      @param columnExpression The expression to provide the value for this column.
        Typically this will simply be a column name.
      @param columnAlias (Optional:'') The name that is to be given to this column
      @return The TSelectColumn that was added.
    ******************************************************************************}
    function Add(const columnExpression : WideString; const columnAlias : WideString = '') : TSelectColumn; overload;

    {******************************************************************************
      Add a column to the list
      @param TableAlias The name of the table the source column is found in.
      @param columnExpression The expression to provide the value for this column.
        Typically this will simply be a column name.
      @param columnAlias The name that is to be given to this column
      @return The TSelectColumn that was added.
    ******************************************************************************}
    function Add(const TableAlias : WideString; const columnExpression : WideString; const columnAlias : WideString) : TSelectColumn; overload;

    {******************************************************************************
      Add multiple columns to the list
      &nbsp;
      Each entry in the array can be [tablealias.](column expr) columnAlias
      Tablealias is delimited by the first period
      Column alias is delimited by the first space that is not in parens or quotes.
      @param columnInfo The string array of column definitions
    ******************************************************************************}
    procedure Add(columnInfo : array of WideString); overload;
    {******************************************************************************
      Add a the TSelectColumn to this collection
      @param Column The TSelectColumn to be added.  If this value is nil, a new
        TSelectColumn is created and added.
      @return The TSelectColumn that is added to the list.
    ******************************************************************************}
    function Add(Column : TSelectColumn) : TSelectColumn; overload;

    {******************************************************************************
      Insert a column into the list at a specific index
      @param columnPos The position in the list where this column is to be added.
        If columnPos is less than 0, the column is inserted as the first item.
        If columnPos is greater than the current number of items in the list,
        the new column is added to the end.
      @param columnExpression The expression to provide the value for this column.
        Typically this will simply be a column name.
      @param columnAlias (Optional:'') The name that is to be given to this column
      @return The TSelectColumn that was added.
    ******************************************************************************}
    function Insert(columnPos: Integer; const columnExpression : WideString; const columnAlias: WideString = ''): TSelectColumn; overload;
    {******************************************************************************
      Insert a column into the list at a specific index
      @param columnPos The position in the list where this column is to be added.
        If columnPos is less than 0, the column is inserted as the first item.
        If columnPos is greater than the current number of items in the list,
        the new column is added to the end.
      @param TableAlias The name of the table the source column is found in.
      @param columnExpression The expression to provide the value for this column.
        Typically this will simply be a column name.
      @param columnAlias The name that is to be given to this column
      @return The TSelectColumn that was added.
    ******************************************************************************}
    function Insert(columnPos: Integer; const tableName, columnName, columnAlias: WideString): TSelectColumn; overload;

    {******************************************************************************
      Insert multiple columns to the list
      &nbsp;
      Each entry in the array can be [tablealias.](column expr) columnAlias
      Tablealias is delimited by the first period
      Column alias is delimited by the first space that is not in parens or quotes.
      @param columnPos The position in the list where the first column is to be
        added. If columnPos is less than 0, the columns are inserted at front.
        If columnPos is greater than the current number of items in the list,
        the new columns are added to the end.
      @param columnInfo The string array of column definitions
    ******************************************************************************}
    procedure Insert(columnPos: Integer; columnInfo: array of WideString); overload;

    {******************************************************************************
      Insert a the TSelectColumn into this collection at a specific point
      @param columnPos The position in the list where the first column is to be
        added. If columnPos is less than 0, the columns are inserted at front.
        If columnPos is greater than the current number of items in the list,
        the new columns are added to the end.
      @param Column The TSelectColumn to be inserted.  If this value is nil,
        a new TSelectColumn is created and added.
      @return The TSelectColumn that is added to the list.
    ******************************************************************************}
    function Insert(Idx : Integer; Column : TSelectColumn) : TSelectColumn; overload;

    {******************************************************************************
      The columns defined in this list.
      &nbsp;
      Key Can be either the Column alias to be found or the Integer Index
        of the Column in the list.
    ******************************************************************************}
    property Column[Key : Variant] : TSelectColumn read GetColumn; default;
  end;

  {******************************************************************************
    Defines a column to be used to order the result set
  ******************************************************************************}
  TOrderByColumn = class(TColumn)
  private
    fDescending : Boolean;
  protected
    {******************************************************************************
      Getter for Descending property
      @group Getters
    ******************************************************************************}
    function GetDescending : Boolean;
    {******************************************************************************
      Setter for Descending property
      @group Setters
    ******************************************************************************}
    procedure SetDescending(Value : Boolean);
  public
//    constructor Create(columnExpression : WideString); overload; override;
//    constructor Create(tableAlias : WideString; columnExpression : WideString); overload; override;

    {******************************************************************************
      TOrderByColumn implementation of ISQLElement buildSQL() workhorse method.
      @param sql The TWideStringBuffer that is being used to accumulate the SQL
        command.
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The string prefix to be appended to front of each line
        of the SQL command.  This is really only to make the final command
        look pretty.  By default the top level starts with an empty string
        and it is up to the buildSQL() implementations to append STD_INDENT
        to the indent it was given for each lower level SQL Element.
      @see ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); override;

    procedure Assign(Source : TPersistent); override;

  published
    {******************************************************************************
      Defined in TTable. Moved to published here.
    ******************************************************************************}
    property TableName;
    {******************************************************************************
      Defined in TTable. Moved to published here.
    ******************************************************************************}
    property ColumnName;
    {******************************************************************************
      Should this column have the "DESC" appended to it.
    ******************************************************************************}
    property Descending : Boolean read GetDescending write SetDescending;
  end;

  {******************************************************************************
    The list of Ordering Columns
  ******************************************************************************}
  TOrderList = class(TCustomColumnList)
  private
  protected
    {******************************************************************************
      Getter for Order property
      @param Key Can be either the Column alias to be found or the Integer Index
        of the Column in the list.
      @group Getters
    ******************************************************************************}
    function GetOrder(Key : Variant) : TOrderByColumn;
  public
    {******************************************************************************
      Constructor
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TPersistent = nil);
    {******************************************************************************
      Access to the columns that will be used to order the dataset.
      &nbsp;
      Key Can be either the Column alias to be found or the Integer Index
        of the Column in the list.
    ******************************************************************************}
    property Order[Key : Variant] : TOrderByColumn read GetOrder; default;


    {******************************************************************************
      Add an ordering column from a Select column
      @param column The TSelectColumn to be used or order the result set.
      @return The TOrderByColumn that was added.
    ******************************************************************************}
    function Add(column: TSelectColumn): TOrderByColumn; overload;

    {******************************************************************************
      Add an ordering column to the list
      @param columnExpression The expression to provide the value for this column.
        Typically this will simply be a column name.
      @return The TOrderColumn that was added.
    ******************************************************************************}
    function Add(const columnExpression: WideString): TOrderByColumn; overload;
    {******************************************************************************
      Add an ordering column to the list
      @param TableAlias The name of the table the source column is found in.
      @param columnExpression The expression to provide the value for this column.
        Typically this will simply be a column name.
      @return The TOrderColumn that was added.
    ******************************************************************************}
    function Add(const tableAlias, columnExpression : WideString) : TOrderByColumn; overload;
    {******************************************************************************
      Add an ordering column to the list
      &nbsp;
      This will change the owning TCollection for the TOrderByColumn
      @param Order The TOrderByColumn to added to this column list.  If Order
        is nil a new TOrderByColumn will be created and added.
      @return The TOrderColumn that was added.
    ******************************************************************************}
    function Add(Order : TOrderByColumn) : TOrderByColumn; overload;

    {******************************************************************************
      Add a group of columns to the Order By Clause.
      @param Columns A String aray of column names or expressions to be added.
    ******************************************************************************}
    procedure AddColumns(Columns : array of WideString);


    {******************************************************************************
      Insert an ordering column from a Select column into a specific position
      @parm orderPosition The integer position where this column is to be
        inserted.
      @param column The TSelectColumn to be used or order the result set.
      @return The TOrderByColumn that was added.
    ******************************************************************************}
    function Insert(orderPosition: Integer; column: TSelectColumn): TOrderByColumn; overload;
    {******************************************************************************
      Insert an ordering column to the list into a specific position
      @parm orderPosition The integer position where this column is to be
        inserted.
      @param columnExpression The expression to provide the value for this column.
        Typically this will simply be a column name.
      @return The TOrderColumn that was added.
    ******************************************************************************}
    function Insert(orderPosition: Integer; const columnExpression: WideString): TOrderByColumn; overload;
    {******************************************************************************
      Insert an ordering column to the list into a specific position
      @parm orderPosition The integer position where this column is to be
        inserted.
      @param TableAlias The name of the table the source column is found in.
      @param columnExpression The expression to provide the value for this column.
        Typically this will simply be a column name.
      @return The TOrderColumn that was added.
    ******************************************************************************}
    function Insert(orderPosition : Integer; const tableName, columnName : WideString) : TOrderByColumn; overload;

    {******************************************************************************
      Insert an ordering column to the list into a specific position
      &nbsp;
      This will change the owning TCollection for the TOrderByColumn
      @parm orderPosition The integer position where this column is to be
        inserted.
      @param Order The TOrderByColumn to added to this column list.  If Order
        is nil a new TOrderByColumn will be created and added.
      @return The TOrderColumn that was added.
    ******************************************************************************}
    function Insert(Idx : Integer; Order : TOrderByColumn) : TOrderByColumn; overload;
  end;

  {******************************************************************************
     Defines a column to be used for grouping the rows of a Result Set
  ******************************************************************************}
  TGroupByColumn = class(TColumn)
  published
    {******************************************************************************
      Exposes the TableName property defined in the TColumn class
    ******************************************************************************}
    property TableName;
    {******************************************************************************
      Exposes the ColumnName defined in the TColumn class
    ******************************************************************************}
    property ColumnName;
  end;

  {******************************************************************************
    Defines a list of GROUP BY columns
  ******************************************************************************}
  TGroupByColumnList = class(TCustomColumnList)
  protected
    {******************************************************************************
      Getter for Column property
      &nbsp;
      Type specific getter that simply calls the _GetItem() method from
      TSQLElementList
      @param Key This variant value can either be a string key that is passed
        to the Match() method or an integer index into the collection.
      @group Getters
    ******************************************************************************}
    function GetColumn(Key : Variant) : TGroupByColumn;

  public
    {******************************************************************************
      Constructor
      @param AOwner (Optional: nil) The object that will control the life of this
      instance of TGroupByColumnList.  If it's nil the program that creates it
      must handle its destruction.
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TPersistent = nil);

    {******************************************************************************
      Add a GroupBy column
      @param columnExpression The name of one of the columns or an expresion to
        be used to group the data in the ResultSet.  This value will be parsed
        into TableName and ColumnName if it is in the proper format:
        "TableName.ColumnName"
      @return The TGroupByColumn that was created
    ******************************************************************************}
    function Add(const columnExpression : WideString) : TGroupByColumn; overload;
    {******************************************************************************
      Add a GroupBy column
      @param tableAlias The name of the table that holds the column.
      @param columnName The name of one of the columns to be used to group the
        data in the ResultSet.
      @return The TGroupByColumn that was created
    ******************************************************************************}
    function Add(const TableAlias : WideString; const columnName : WideString) : TGroupByColumn; overload;
    {******************************************************************************
      Use the definition of a specific column in the ResultSet to be a part
      of the GROUP BY list.
      @param Column The TSelectColumn to be used to group the rows in the
        ResultSet.
      @return The TGroupByColumn created.
    ******************************************************************************}
    function Add(Column : TSelectColumn) : TGroupByColumn; overload;
    {******************************************************************************
      Add mulitple columns to the GROUP BY list.
      &nbsp;
      Each entry in the array can be [tablealias.](column expr) columnAlias
      Tablealias is delimited by the first period, Column alias is delimited by
      the first space that is not in parens or quotes.
      @param columnInfo The string array of column names
    ******************************************************************************}
    procedure Add(columnInfo : array of WideString); overload;
    {******************************************************************************
      Add a TGroupByColumn to the list.
      &nbsp;
      The parent collection of the TGroupByColumn will be changed to this
      TGroupByList.
      @param Column The TGroupByColumn to be added. If this value is nil a
        new TGroupByColumn will be created.
      @return The TGroupByColumn added to the list.
    ******************************************************************************}
    function Add(Column : TGroupByColumn) : TGroupByColumn; overload;

    {******************************************************************************
      Insert a GroupBy column at a specific position
      @parm columnPos The position in the list where this column should be added.
        If the value is less than 0, the column is added to the front of the
        list,  If value is greater than the current number of items in the list
        the new column is added to the end of the list.
      @param columnExpression The name of one of the columns or an expresion to
        be used to group the data in the ResultSet.  This value will be parsed
        into TableName and ColumnName if it is in the proper format:
        "TableName.ColumnName"
      @return The TGroupByColumn that was created
    ******************************************************************************}
    function Insert(columnPos: Integer; const columnExpression : WideString): TGroupByColumn; overload;
    {******************************************************************************
      Insert a GroupBy column at a specific position
      @parm columnPos The position in the list where this column should be added.
        If the value is less than 0, the column is added to the front of the
        list,  If value is greater than the current number of items in the list
        the new column is added to the end of the list.
      @param tableAlias The name of the table that holds the column.
      @param columnName The name of one of the columns to be used to group the
        data in the ResultSet.
      @return The TGroupByColumn that was created
    ******************************************************************************}
    function Insert(columnPos: Integer; const tableName, columnName: WideString): TGroupByColumn; overload;
    {******************************************************************************
      Use the definition of a specific column in the ResultSet to be a part
      of the GROUP BY list.
      @parm columnPos The position in the list where this column should be added.
        If the value is less than 0, the column is added to the front of the
        list,  If value is greater than the current number of items in the list
        the new column is added to the end of the list.
      @param Column The TSelectColumn to be used to group the rows in the
        ResultSet.
      @return The TGroupByColumn created.
    ******************************************************************************}
    function Insert(columnPos : Integer; Column : TSelectColumn) : TGroupByColumn; overload;
    {******************************************************************************
      Insert mulitple columns to the GROUP BY list.
      &nbsp;
      Each entry in the array can be [tablealias.](column expr) columnAlias
      Tablealias is delimited by the first period, Column alias is delimited by
      the first space that is not in parens or quotes.
      @parm columnPos The position in the list where the first column should be
        added. If the value is less than 0, the columns are added to the front
        of the list,  If value is greater than the current number of items in
        the list the new columns are added to the end of the list.
      @param columnInfo The string array of column names
    ******************************************************************************}
    procedure Insert(columnPos: Integer; columnInfo: array of WideString); overload;
    {******************************************************************************
      Insert a TGroupByColumn to the list.
      &nbsp;
      The parent collection of the TGroupByColumn will be changed to this
      TGroupByList.
      @parm columnPos The position in the list where this column should be added.
        If the value is less than 0, the column is added to the front of the
        list,  If value is greater than the current number of items in the list
        the new column is added to the end of the list.
      @param Column The TGroupByColumn to be added. If this value is nil a
        new TGroupByColumn will be created.
      @return The TGroupByColumn added to the list.
    ******************************************************************************}
    function Insert(Idx : Integer; Column : TGroupByColumn) : TGroupByColumn; overload;

    {******************************************************************************
      The columns already defined in the list.
    ******************************************************************************}
    property Column[Key : Variant] : TGroupByColumn read GetColumn; default;
  end;

  {******************************************************************************
    The type of JOIN that is represented by the TJoinTable
    <TABLE>
    <TR><TD>&nbsp(4);</TD><TD>jtJoin =</TD><TD>INNER JOIN</TD></TR>
    <TR><TD>&nbsp(4);</TD><TD>ltLeftJoin =</TD><TD>LEFT OUTER JOIN</TD></TR>
    <TR><TD>&nbsp(4);</TD><TD>ltRightJoin =</TD><TD>RIGHT OUTER JOIN</TD></TR>
    <TR><TD>&nbsp(4);</TD><TD>ltFullJoin =</TD><TD>FULL OUTER JOIN</TD></TR></TABLE>
    @see TJoinTable
  ******************************************************************************}
  TJoinType = (jtJoin, jtLeftJoin, jtRightJoin, jtFullJoin);

  {******************************************************************************
    Holds the definition of table to be joined to
  ******************************************************************************}
  TJoinTable = class(TFromTable)
  private
    fJoinType : TJoinType;
    fJoinOnConditions : TConditionList;
  protected
    {******************************************************************************
      Getter for JoinOn property
      @group Getters
    ******************************************************************************}
    function GetJoinOnConditions : TConditionList; virtual;
    {******************************************************************************
      Setter for JoinOn property
      @group Setters
    ******************************************************************************}
    procedure SetJoinOnConditions(const Value : TConditionList);

    {******************************************************************************
      Setter for JoinType property
      @group Setters
    ******************************************************************************}
    procedure SetJoinType(value : TJoinType);

    {******************************************************************************
      Called by BuildSQL to add Join Type
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param sql The TWideStringBuffer containing the sql being built
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildJoinType(sql : TWideStringBuffer; const indent : WideString); virtual;
    {******************************************************************************
      Called by BuildSQL to add ON conditional link
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param sql The TWideStringBuffer containing the sql being built
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildOnLink(sql : TWideStringBuffer;
      parameters : TParameterList; const indent : WideString); virtual;

  public
    {******************************************************************************
      Constructor
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TCollection);
    {******************************************************************************
      Destructor
      @group Constructors
    ******************************************************************************}
    destructor Destroy; override;

    {******************************************************************************
      TJoinTable implementation of ISQLElement buildSQL() workhorse method.
      @param sql The TWideStringBuffer that is being used to accumulate the SQL
        command.
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The string prefix to be appended to front of each line
        of the SQL command.  This is really only to make the final command
        look pretty.  By default the top level starts with an empty string
        and it is up to the buildSQL() implementations to append STD_INDENT
        to the indent it was given for each lower level SQL Element.
      @see ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); override;

    procedure Assign(Source : TPersistent); override;
  published
    {******************************************************************************
      The list of conditions used to govern how the secondary table is linked
      to the primary.
    ******************************************************************************}
    property JoinOn : TConditionList read GetJoinOnConditions write SetJoinOnConditions;
    {******************************************************************************
      The type of Join to be used.
      &nbsp;
      INNER, LEFT OUTER, RIGHT OUTER or FULL OUTER
    ******************************************************************************}
    property JoinType : TJoinType read fJoinType write SetJoinType default jtJoin;
  end;

  TJoinSubSelect = class(TJoinTable)
  public
    property SubSelect;
  end;


  {******************************************************************************
    Holds a list of TJoinTables
    @todo Why does this have two separate properties JoinTo and JoinToByAlias
          when the other lists only have one that will handle both situations?
  ******************************************************************************}
  TJoinTableList = class(TSQLElementList)
  protected
    {******************************************************************************
      Getter for JoinTable property
      @group Getters
    ******************************************************************************}
    function GetJoinTable(Idx: Integer): TJoinTable;
    {******************************************************************************
      Getter for JoinTableByAlias property
      @group Getters
    ******************************************************************************}
    function GetJoinTableByAlias(const alias : WideString) : TJoinTable;

    function CreateJoinTable : TJoinTable; virtual;

  public
    {******************************************************************************
      Constructor
      @param AOwner The object that will control the life of this object.  Can
        be nil if the list will not be used as a child of another object.
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TPersistent);

    {******************************************************************************
      Join to a ResultSet statement
      @param joinToAlias The alias that should be used to reference the ResultSet
        from the subSelect query.
      @param joinOnCondition (Optional) The SQL condition to be used to link the
        primary table to this joined ResultSet.
      @return The TJoinSubSelect added.
    ******************************************************************************}
    function AddSubSelect(const joinToAlias : WideString; const joinOnCondition: WideString = ''; JoinType : TJoinType = jtJoin) : TJoinSubSelect;

    {******************************************************************************
      Join to a ResultSet statement
      @param subSelect The TSQLSelectFactory that holds the query for the
        ResultSet that is to be joined to.
      @param joinToAlias The alias that should be used to reference the ResultSet
        from the subSelect query.
      @param joinOnCondition The SQL condition to be used to link the primary
        table to this joined ResultSet.
      @param joinType The type of join to be performed, jtJoin, jtLeftJoin,
      jtRightJoin or jtFullJoin
      @return The TJoinTable that was added.
      @see TJoinType
    ******************************************************************************}
    function Add(subSelect: TSQLSelectFactory; const joinToAlias, joinOnCondition: WideString; JoinType : TJoinType = jtJoin): TJoinTable; overload;

    {******************************************************************************
      Join to a Table or ResultSet.
      @param joinTableExpression The table name or SQL SELECT statement to be
        joined to. This can contain the Schema and Alias and it will be parsed
        properly.
      @param joinOnCondition The SQL condition to be used to link the primary
        table to this joined Table or ResultSet.
      @param joinType The type of join to be performed, jtJoin, jtLeftJoin,
      jtRightJoin or jtFullJoin
      @return The TJoinTable that was added.
      @see TJoinType
    ******************************************************************************}
    function Add(const joinTableExpression, joinOnCondition: WideString; JoinType : TJoinType = jtJoin): TJoinTable; overload;
    {******************************************************************************
      Join to a Table
      @param joinTableName The name of the table to be joined to.  This can
        contain the Schema and it will be parsed off properly.
      @param joinToAlias The alias to be used to reference the data that is
        added by this join.
      @param joinOnCondition The SQL condition to be used to link the primary
        table to this joined Table.
      @param joinType The type of join to be performed, jtJoin, jtLeftJoin,
      jtRightJoin or jtFullJoin
      @return The TJoinTable that was added.
      @see TJoinType
      @group -- [Constructors , Getters , Setters ]
      @throws -- Exceptions that are actually thrown from this method.
    ******************************************************************************}
    function Add(const joinTableName, joinToAlias, joinOnCondition : WideString; JoinType : TJoinType = jtJoin): TJoinTable; overload;
    {******************************************************************************
      Add a JoinTable to the list
      &nbsp;
      This will change the parent collection to be this TJoinTableList.
      @param JoinTable The TJoinTable to be added to the list.  If the value is
        nil a new TJoinTable will be created.
      @param joinType The type of join to be performed, jtJoin, jtLeftJoin,
      jtRightJoin or jtFullJoin
      @return The TJoinTable that was added.
      @see TJoinType
    ******************************************************************************}
    function Add(JoinTable : TJoinTable) : TJoinTable; overload;

    {******************************************************************************
      Add multiple Joins to the list
      @param joinToInfo The string array that holds the definition of the joins
        to be added.  Each element in the array must be in the following format:<BR/>
      &nbsp(4);TableName,Alias,Link Condition
      @param joinType The type of join to be performed, jtJoin, jtLeftJoin,
      jtRightJoin or jtFullJoin
      @see TJoinType
    ******************************************************************************}
    procedure Add(joinToInfo: array of WideString; JoinType : TJoinType = jtJoin); overload;

    {******************************************************************************
      TJoinTableList implementation of ISQLElement buildSQL() workhorse method.
      @param sql The TWideStringBuffer that is being used to accumulate the SQL
        command.
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The string prefix to be appended to front of each line
        of the SQL command.  This is really only to make the final command
        look pretty.  By default the top level starts with an empty string
        and it is up to the buildSQL() implementations to append STD_INDENT
        to the indent it was given for each lower level SQL Element.
      @see ISQLElement
    ******************************************************************************}
    procedure BuildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent: WideString); override;

    {******************************************************************************
      Access to the TJoinTables by Index
    ******************************************************************************}
    property JoinTable[Idx : Integer] : TJoinTable read GetJoinTable; default;
    {******************************************************************************
      Access to the TJoinTables by their Alias.
    ******************************************************************************}
    property JoinTableByAlias[const Alias : WideString] : TJoinTable read GetJoinTableByAlias;
  end;

  {******************************************************************************
    A condition that tests if a value is in a sub-select result set.
    @see SQLFactoryBase.TSimpleCondition
    @see SQLFactoryBase.TConditionGroup
    @see SQLFactoryBase.TINCondition
  ******************************************************************************}
  TINSelectCondition = class(TCondition)
  private
    fValueExpression : WideString;
    fSubSelect : TSQLSelectFactory;
  protected
    function GetSubSelect : TSQLSelectFactory; virtual;
    procedure SetSubSelect(const Value : TSQLSelectFactory); virtual;

    function InternalCreateSubSelect : TSQLSelectFactory; virtual;

  public
    {******************************************************************************
      Constructor
      @param AOwner The Collection that will control the life of this item.
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TCollection); overload;
    {******************************************************************************
      Constructor
      @param AOwner The Collection that will control the life of this item.
      @param ValueExpression The SQL expression that is to be searched for.
      @param subSelect The TSQLSelectFactory that holds the definition of the
        SQL SELECT query that will generate the ResultSet to be searched.
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TCollection; const ValueExpression: WideString; subSelect : TSQLSelectFactory); overload;
    {******************************************************************************
      Destructor
      @group Constructors
    ******************************************************************************}
    destructor Destroy; override;

    {******************************************************************************
      Assign the values of the other TINSelectCondition to this TINSelectCondition.
      @param Other The other TINSelectCondition whose values are to be copied to
        this TINSelectCondition.  The inherited Assign() is then called.
      @throws EConvertError
    ******************************************************************************}
    procedure Assign(Other : TPersistent); override;

    {******************************************************************************
      Return a description of this TCollectionItem
      &nbsp;
      This method is used to describe TCollectionItems in the Designer.
      @return A string description based on this items parents and the SQL
        snippet it contains.
    ******************************************************************************}
    function GetDisplayName : String; override;

    {******************************************************************************
      TINSelectCondition implementation of ISQLElement buildSQL() workhorse method.
      @param sql The TWideStringBuffer that is being used to accumulate the SQL
        command.
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The string prefix to be appended to front of each line
        of the SQL command.  This is really only to make the final command
        look pretty.  By default the top level starts with an empty string
        and it is up to the buildSQL() implementations to append STD_INDENT
        to the indent it was given for each lower level SQL Element.
      @see ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList = nil; const indent : WideString = ''); override;
  published
    {******************************************************************************
      The value to be searched for in the ResultSet
    ******************************************************************************}
    property ValueExpression : WideString read fValueExpression write fValueExpression;
    {******************************************************************************
      The TSQLSelectFactory that holds the definition of the SQL SELECT that
      will provide the ResultSet to be searched.
    ******************************************************************************}
    property SubSelect : TSQLSelectFactory read GetSubSelect write SetSubSelect;
  end;

  TConditionListX = class(TConditionList)
  public
    function AddInSelect(ValueExpression : WideString; SubSelect : TSQLSelectFactory=nil) : TINSelectCondition; virtual;
  end;

  {******************************************************************************
    The SQL Factory that holds the definition of a SQL SELECT statement
  ******************************************************************************}
  TSQLSelectFactory = class(TSQLElementParent)
  private
    fFromTable : TFromTable;
    fTopCount : Integer;
    fDistinct : Boolean;
    fColumns : TSelectColumnList;
    fJoinTos : TJoinTableList;
    fWhereClauses : TConditionListX;
    fAdditionalConditions : TConditionList;
    fHavingClauses : TConditionList;
    fOrderBys : TOrderList;
    fGroupBys : TGroupByColumnList;
  protected
    {******************************************************************************
      Getter for FromTable property
      @group Getters
    ******************************************************************************}
    function Get_FromTable : TFromTable;
    {******************************************************************************
      Getter for Columns property
      @group Getters
    ******************************************************************************}
    function Get_Columns : TSelectColumnList;
    {******************************************************************************
      Getter for JoinTo property
      @group Getters
    ******************************************************************************}
    function Get_JoinTos : TJoinTableList; virtual;
    {******************************************************************************
      Getter for Where property
      @group Getters
    ******************************************************************************}
    function Get_WhereClauses : TConditionListX; virtual;
    {******************************************************************************
      Getter for AdditionalConditions property
      @group Getters
    ******************************************************************************}
    function Get_AdditionalConditions : TConditionList;
    {******************************************************************************
      Getter for Having property
      @group Getters
    ******************************************************************************}
    function Get_HavingClauses : TConditionList;
    {******************************************************************************
      Getter for OrderBy property
      @group Getters
    ******************************************************************************}
    function Get_Order : TOrderList;
    {******************************************************************************
      Getter for GroupBy property
      @group Getters
    ******************************************************************************}
    function Get_GroupBys : TGroupByColumnList;
    {******************************************************************************
      Getter for TopCount property
      @group Getters
    ******************************************************************************}
    function Get_TopCount: Integer;

    {******************************************************************************
      Getter for Distinct property
      @group Getters
    ******************************************************************************}
    function Get_Distinct : Boolean;

    {******************************************************************************
      Setter for FromTable property
      @group Setters
    ******************************************************************************}
    procedure Set_FromTable(const Value : TFromTable); overload;
    {******************************************************************************
      Setter for Columns property
      @group Setters
    ******************************************************************************}
    procedure Set_Columns(const Value : TSelectColumnList);
    {******************************************************************************
      Setter for JoinTo property
      @group Setters
    ******************************************************************************}
    procedure Set_JoinTos(const Value : TJoinTableList);
    {******************************************************************************
      Setter for Where property
      @group Setters
    ******************************************************************************}
    procedure Set_WhereClauses(const Value : TConditionListX); virtual;
    {******************************************************************************
      Setter for AdditionalConditions property
      @group Setters
    ******************************************************************************}
    procedure Set_AdditionalConditions(const Value : TConditionList);
    {******************************************************************************
      Setter for Having property
      @group Setters
    ******************************************************************************}
    procedure Set_HavingClauses(const Value : TConditionList);
    {******************************************************************************
      Setter for OrderBy property
      @group Setters
    ******************************************************************************}
    procedure Set_Order(const Value : TOrderList);
    {******************************************************************************
      Setter for GroupBy property
      @group Setters
    ******************************************************************************}
    procedure Set_GroupBys(const Value : TGroupByColumnList);
    {******************************************************************************
      Setter for TopCount property
      @group Setters
    ******************************************************************************}
    procedure Set_TopCount(const Value: Integer);

    {******************************************************************************
      Setter for Distinct property
      @group Setters
    ******************************************************************************}
    procedure Set_Distinct(const Value : Boolean);
  protected
    procedure InternalBuildColumnList(sql : TWideStringBuffer;
                        parameters : TParameterList; const Indent : WideString); virtual;
    procedure InternalBuildFromClause(sql : TWideStringBuffer;
                        parameters : TParameterList; const Indent : WideString); virtual;
    procedure InternalBuildJoinClauses(sql : TWideStringBuffer;
                        parameters : TParameterList; const Indent : WideString); virtual;
    procedure InternalBuildWhereClause(sql : TWideStringBuffer;
                        parameters : TParameterList; const Indent : WideString); virtual;
    procedure InternalBuildGroupClause(sql : TWideStringBuffer;
                        parameters : TParameterList; const Indent : WideString); virtual;
    procedure InternalBuildHavingClause(sql : TWideStringBuffer;
                        parameters : TParameterList; const Indent : WideString); virtual;
    procedure InternalBuildOrderClause(sql : TWideStringBuffer;
                        parameters : TParameterList; const Indent : WideString); virtual;
  public
    {******************************************************************************
      Constructor
      @param AOwner The object that will control the life of this factory. This
        value can be passed in as a nil.
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TPersistent=nil);
    {******************************************************************************
      Destructor
      @group Constructors
    ******************************************************************************}
    destructor Destroy; override;

    {******************************************************************************
      Clear all the properties of the Factory
    ******************************************************************************}
    procedure Clear; virtual;
    {******************************************************************************
      Parse a SQL SELECT statement into this factory
      @param SQL The string that contains the SQL SELECT statement to be parsed.
      @see SQLParser.ParseSQLSelect
    ******************************************************************************}
    procedure ParseSQL(const SQL : WideString);

    {******************************************************************************
      TSQLSelectFactory implementation of ISQLElement buildSQL() workhorse method.
      &nbsp;
      This implementation simply calls the BuildSQL() method on it's children
      in the proper order to create a valid SQL SELECT query.
      @param sql The TWideStringBuffer that is being used to accumulate the SQL
        command.
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The string prefix to be appended to front of each line
        of the SQL command.  This is really only to make the final command
        look pretty.  By default the top level starts with an empty string
        and it is up to the buildSQL() implementations to append STD_INDENT
        to the indent it was given for each lower level SQL Element.
      @see ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); overload; override;

    {******************************************************************************
      Generate a TPRADOQuery from the current values in this factory.
      &nbsp;
      It is the responsibility of the calling routine to clean up the TPRADOQuery.
      @param connection The TPRADOConnection to be used to execute the query.
      @param ExecuteOptions (Optional: []) The async/sync options that are to
        be used to control the execution of this query.
      @param Open (Optional: True) If false, the TPRADOQuery will be setup but
        the query will not actually be run.
      @return A TPRADOQuery with the SQL property set to the SQL SELECT defined
        by this factory.
    ******************************************************************************}
    function prepareQuery(Connection : TPRADOConnection;
                          ExecuteOptions : TExecuteOptions = [];
                          Open : WordBool = true) : TPRADOQuery;  overload;

    {******************************************************************************
      Populate a TPRADOQuery from the current values in this factory.
      @param Query The TPRADOQuery that is to be assigned the SQL SELECT defined
        by this factory.  If it is open, it will be automatically closed before
        it's SQL property is changed.
      @param ExecuteOptions (Optional: []) The async/sync options that are to
        be used to control the execution of this query.
      @param Open (Optional: True) If false, the TPRADOQuery will be setup but
        the query will not actually be run.
    ******************************************************************************}
    procedure prepareQuery(Query : TCustomADODataSet;
                           ExecuteOptions : TExecuteOptions = [];
                           Open : WordBool = true); overload;

    {******************************************************************************
      Conditions that are added to the WHERE clause of the SQL SELECT
      &nbsp;
      The purpose of this property is to allow the developer to define a standard
      set of conditions on the Where property but then filter the result set with
      a more dynamic set of conditions.
      @see TSQLSelectFactory.Where
    ******************************************************************************}
    property AdditionalConditions : TConditionList read Get_AdditionalConditions write Set_AdditionalConditions;


    procedure Assign(Source : TPersistent); override;
  published
    {******************************************************************************
      The table or SQL SELECT to be the primary source of data for the ResultSet.
    ******************************************************************************}
    property FromTable : TFromTable read Get_FromTable write Set_FromTable;
    {******************************************************************************
      The list of columns to be returned in the ResultSet.
      &nbsp;
      If no columns are defined, the default All Columns symbol, an asterisk, '*'
      is placed into the generated SQL SELECT statement.
    ******************************************************************************}
    property Columns : TSelectColumnList read Get_Columns write Set_Columns;
    {******************************************************************************
      The list of table and SQL SELECT's to be joined to the primary table to
      provide data for the Result Set.
    ******************************************************************************}
    property JoinTo : TJoinTableList read Get_JoinTos write Set_JoinTos;
    {******************************************************************************
      The list of conditions to be used to control what data will be returned
      in the ResultSet.
      &nbsp;
      The conditions in the Where property are of a more permanent nature.  If
      conditions are more dyanamic you may want to consider using the
      AdditionalConditions property.
      @see TSQLSelectFactory.AdditionalConditions
    ******************************************************************************}
    property Where : TConditionListX read Get_WhereClauses write Set_WhereClauses;
    {******************************************************************************
      The list of conditions to be applied to the ResultSet after it has been
      generated but before it is returned.
    ******************************************************************************}
    property Having : TConditionList read Get_HavingClauses write Set_HavingClauses;
    {******************************************************************************
      The list of columns to be used to order the ResultSet.
    ******************************************************************************}
    property OrderBy : TOrderList read Get_Order write Set_Order;
    {******************************************************************************
      The list of columns to be used to group data in the ResultSet when
      aggregate functions are used.
    ******************************************************************************}
    property GroupBy : TGroupByColumnList read Get_GroupBys write Set_GroupBys;
    {******************************************************************************
      The number of rows on the top of the ResultSet are to be returned.
      &nbsp;
      Defaults to all rows.
    ******************************************************************************}
    property TopCount : Integer read Get_TopCount write Set_TopCount;

    {******************************************************************************
      Select only distinct rows of values
      &nbsp;
      Defaults to selecting all rows, not just distinct values.
    ******************************************************************************}
    property Distinct : Boolean read Get_Distinct write Set_Distinct;
  end;

implementation

uses
  Math
  ,  CommonObjLib
  , CommonStringLib
  , Variants
  {$IFDEF PERFTIMER}
  , PerformanceTimer
  {$ENDIF}
  , DB
  , StrUtils
  , SQLParser, Clipbrd
  ;

{ TFromTable }
//constructor TFromTable.Create(AOwner : TPersistent);
//begin
//  inherited Create(nil);
//  fOwner := AOwner;
//end;

destructor TFromTable.Destroy;
begin
  SafeFree(fSubSelect);

  inherited;
end;

//function TFromTable.GetOwner : TPersistent;
//begin
//  Result := fOwner;
//end;
//
function TFromTable.GetSubSelect : TSQLSelectFactory;
begin
  if (fSubSelect = nil) then begin
    if (TableAlias = '') then begin
      TableAlias := tableName;
      TableName := '';
    end;
    fSubSelect := InternalCreateSubSelect;
  end;
  Result := fSubSelect;
end;

function TFromTable.GetIsSubSelect : Boolean;
begin
  Result := (fSubSelect <> nil);
end;

procedure TFromTable.SetSubSelect(const Value : TSQLSelectFactory);
begin
  if (fSubSelect <> nil) then
    SafeFree(fSubSelect);
  if (value <> nil) then begin
    Self.TableSchema := '';
    Self.TableName := '';
  end;
  fSubSelect := Value;
end;

procedure TFromTable.SetTableSchema(const Value : WideString);
begin
  inherited SetTableSchema(Value);
  SetSubSelect(nil);
end;

procedure TFromTable.SetTableName(const Value : WideString);
begin
  inherited SetTableName(Value);
  SetSubSelect(nil);
end;

function TFromTable.Get_Hint : WideString;
begin
  Result := fHint;
end;

procedure TFromTable.Set_Hint(const Value : WideString);
Var
  p : Integer;
begin
  if StringMatch('WITH', Value, [moIgnoreCase, moIgnoreSpaces, moPartialMatchLeft]) then begin
    p := Pos('WITH', UpperCase(Value));
    fHint := Trim(Copy(Value, p + 1, Length(Value)));
    if (Copy(fHint, 1, 1) = '(') then
      fHint := trim(Copy(fHint, 2, Length(fHint)));
    if (Copy(fHint, Length(fHint), 1) = ')') then
      fHint := Trim(Copy(fHint, 1, Length(fHint)-1));
  end
  else
    fHint := Value;
end;


procedure TFromTable.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  InternalBuildFromSource(sql, parameters, indent);
end;

procedure TFromTable.InternalBuildFromSource(sql : TWideStringBuffer;
  parameters : TParameterList; const indent : WideString);
begin
  if (fSubSelect <> nil) and (fSubSelect.FromTable.TableName <> '') then begin
    InternalBuildSubSelect(sql, parameters, indent);
  end
  else begin
    InternalBuildFullTableIdentifier(sql, indent);
    InternalBuildParameters(parameters);
  end;
end;

procedure TFromTable.InternalBuildFullTableIdentifier(sql: TWideStringBuffer;
  const indent : WideString);
begin
  inherited InternalBuildFullTableIdentifier(sql, indent);
  if (not IsEmpty(fHint)) then begin
    SQL.Append(' WITH (');
    SQL.Append(fHint);
    SQL.Append(')');
  end;
end;

procedure TFromTable.InternalBuildSubSelect(sql : TWideStringBuffer;
  parameters : TParameterList; const indent : WideString);
begin
    sql.append('(');
    sql.append(#13#10);
    sql.Append(indent);
    SubSelect.buildSQL(sql, parameters, indent + STD_INDENT);
    sql.append(#13#10);
    sql.Append(indent);
    sql.append(') ');
    if (AddDelimiters) then
      sql.Append('[');
    if (tableAlias <> '') then
      sql.append(TableAlias)
    else if (TableName <> '') then
      sql.append(TableName)
    else
      sql.append('JoinAlias' + IntToStr(Self.ID));

    if (AddDelimiters) then
      sql.Append(']');
end;

function TFromTable.InternalCreateSubSelect : TSQLSelectFactory;
begin
  Result := TSQLSelectFactory.Create(Self);
end;


procedure TFromTable.Assign(Source: TPersistent);
begin
  inherited;
  if (Source <> nil) and (Source is TFromTable) then
    if (TFromTable(Source).fSubSelect <> nil) then
      Self.SubSelect.Assign(TFromTable(Source).fSubSelect)
    else
      Self.SubSelect := nil;
end;



{ TSelectColumn }

function TSelectColumn.GetColumnAlias: WideString;
begin
  Result := fColumnAlias;
end;

procedure TSelectColumn.SetColumnAlias(const Value : WideString);
begin
  fColumnAlias := Value;
end;

function TSelectColumn.GetIsNullDefault: WideString;
begin
  Result := fIsNullDefault;
end;

procedure TSelectColumn.SetIsNullDefault(const Value: WideString);
begin
  fIsNulLDefault := Value;
end;



procedure TSelectColumn.buildSQL(sql: TWideStringBuffer; parameters: TParameterList;
  const indent : WideString = '');
begin
  if (not IsEmpty(IsNullDefault)) then
    sql.append('isNull(');

  inherited BuildSQL(Sql, parameters, indent);

  if (not IsEmpty(IsNullDefault)) then begin
    sql.append(',');
    sql.append(IsNullDefault);
    sql.append(')');
  end;

  if   ( (columnName <> columnAlias) or (not IsEmpty(IsNullDefault)) )
   and (columnAlias <> '')
  then begin
    sql.append(' ');
    sql.append(EnforceBrackets('[', columnAlias, ']'));
  end;
end;

function TSelectColumn.Match(const Str : WideString) : Boolean;
begin
  Result := StringMatch(ColumnAlias, Str);
end;

procedure TSelectColumn.Assign(Source: TPersistent);
begin
  inherited;
  if (Source <> nil) and (Source is TSelectColumn) then begin
    Self.ColumnAlias := TSelectColumn(Source).ColumnAlias;
  end;
end;

{ TSelectColumnList }

constructor TSelectColumnList.Create(AOwner : TPersistent);
begin
  inherited Create(AOwner, TSelectColumn);
end;

function TSelectColumnList.GetColumn(Key : Variant): TSelectColumn;
begin
  Result := TSelectColumn(GetField(Key));
end;

function TSelectColumnList.Add(const columnExpression : WideString; const columnAlias : WideString = ''): TSelectColumn;
begin
  Result := insert(Count, columnExpression, columnAlias);
end;

function TSelectColumnList.Add(const tableAlias, columnExpression, columnAlias: WideString): TSelectColumn;
begin
  Result := insert(Count, tableAlias, columnExpression, columnAlias);
end;

procedure TSelectColumnList.Add(columnInfo: array of WideString);
begin
  insert(Count, columnInfo);
end;

function TSelectColumnList.Insert(columnPos: Integer; const columnExpression : WideString; const columnAlias: WideString = ''): TSelectColumn;
Var
  tmpTableAlias, tmpColumnExpression, tmpColumnAlias : WideString;
begin
  tmpTableAlias := '';
  tmpColumnExpression := columnExpression;
  tmpColumnAlias := columnAlias;
  if (columnAlias = '') then
    ParseColumnInfo(columnExpression, tmpTableAlias, tmpColumnExpression, tmpColumnAlias);
  Result := insert(columnPos, tmpTableAlias, tmpColumnExpression, tmpColumnAlias);
end;

function TSelectColumnList.Insert(columnPos: Integer; const tableName, columnName, columnAlias: WideString): TSelectColumn;
begin
  Result := TSelectColumn.Create(Self);
  Result.Index := ColumnPos;
  Result.TableName := tableName;
  Result.ColumnName := columnName;
  if (ColumnAlias = '') then
    Result.ColumnAlias := columnName
  else
    Result.ColumnAlias := columnAlias;
end;

procedure TSelectColumnList.Insert(columnPos: Integer; columnInfo: array of WideString);
Var
  i, p : Integer;
  tmpColumnExpression, tmpColumnName : WideString;
begin
  for i := High(columnInfo) downto 0 do begin
    p := 1;
    tmpColumnExpression := ParseNext(p, columnInfo[i], ', ', '"[]');
    tmpColumnName := ParseNext(p, columnInfo[i], ', ', '"[]');
    insert(columnPos, tmpColumnExpression, tmpColumnName);
  end;
end;

function TSelectColumnList.Add(Column: TSelectColumn) : TSelectColumn;
begin
  Result := TSelectColumn(InsertItem(Column));
end;

function TSelectColumnList.Insert(Idx: Integer; Column: TSelectColumn) : TSelectColumn;
begin
  Result := TSelectColumn(InsertItem(Column, Idx));
end;

{ TOrderByColumn }
//
//constructor TOrderByColumn.Create(columnExpression : WideString);
//begin
//  Self.Create('', columnExpression);
//end;
//
//constructor TOrderByColumn.Create(tableAlias, columnExpression: WideString);
//begin
//  inherited Create(tableAlias, columnExpression);
//
//  fDescending := False;
//end;

function TOrderByColumn.GetDescending: Boolean;
begin
  Result := fDescending;
end;

procedure TOrderByColumn.SetDescending(Value: Boolean);
begin
  fDescending := Value;
end;

procedure TOrderByColumn.buildSQL(sql: TWideStringBuffer; parameters: TParameterList; const indent : WideString = '');
begin
  inherited buildSQL(sql, parameters, indent);
  if (descending) then
    sql.append(' DESC ');
end;

procedure TOrderByColumn.Assign(Source : TPersistent);
begin
  inherited;
  if (Source <> nil) and (Source is TOrderByColumn) then begin
    Self.Descending := TOrderByColumn(Source).Descending;
  end;
end;


{ TOrderList }

constructor TOrderList.Create(AOwner : TPersistent);
begin
  inherited Create(AOwner, TOrderByColumn);
end;

function TOrderList.GetOrder(Key : Variant): TOrderByColumn;
begin
  Result := TOrderByColumn(GetField(Key));
end;

function TOrderList.Add(Order: TOrderByColumn) : TOrderByColumn;
begin
  Result := TOrderByColumn(InsertItem(Order));
end;

function TOrderList.Add(const columnExpression: WideString): TOrderByColumn;
begin
  Result := insert(Count, columnExpression);
end;

procedure TOrderList.AddColumns(Columns : array of WideString);
Var
  i : Integer;
begin
  for I := Low(Columns) to High(Columns) do
    Add(Columns[i]);
end;

function TOrderList.Add(const tableAlias, columnExpression : WideString) : TOrderByColumn;
begin
  Result := insert(Count, tableAlias, columnExpression);
end;

function TOrderList.Add(column: TSelectColumn): TOrderByColumn;
begin
  Result := insert(Count, column);
end;

function TOrderList.Insert(orderPosition: Integer; column: TSelectColumn): TOrderByColumn;
begin
  if (column = nil) then begin
    Result := nil;
    Exit;
  end;
  // We don't want to use the actual column definition because it may
  // contain an alias and it's life is controlled by its own
  // column list.
  Result := insert(orderPosition, column.TableName, column.ColumnName);
end;

function TOrderList.Insert(orderPosition: Integer; const columnExpression: WideString): TOrderByColumn;
begin
  Result := Insert(orderPosition, '', ColumnExpression);
end;

function TOrderList.Insert(orderPosition : Integer; const tableName, columnName : WideString) : TOrderByColumn;
Var
  tmp : WideString;
  p : Integer;
begin
  Result := TOrderByColumn.Create(Self);
  Result.Index := orderPosition;
  Result.tableName := tableName;
  tmp := Trim(ColumnName);
  p := Pos(' DESC', UpperCase(tmp));
  // ColumnName isn't DESC but the specification has DESC at the end.
  if (p > 1) and (p = (Length(tmp)-4)) then begin
    Result.Descending := True;
    Result.ColumnName := Copy(tmp, 1, p-1);
  end
  else
    Result.ColumnName := columnName;
end;

function TOrderList.Insert(Idx: Integer; Order: TOrderByColumn) : TOrderByColumn;
begin
  Result := TOrderByColumn(InsertItem(Order, Idx));
end;

{ TGroupByColumnList }
constructor TGroupByColumnList.Create(AOwner: TPersistent = nil);
begin
  inherited Create(AOwner, TGroupByColumn);
end;

function TGroupByColumnList.GetColumn(Key: Variant): TGroupByColumn;
begin
  Result := TGroupByColumn(GetField(Key));
end;

function TGroupByColumnList.Add(const columnExpression: WideString): TGroupByColumn;
begin
  Result := Add('', columnExpression);
end;

function TGroupByColumnList.Add(const TableAlias, columnName: WideString): TGroupByColumn;
begin
  Result := insert(Count, tableAlias, columnName);
end;

function TGroupByColumnList.Add(Column : TSelectColumn) : TGroupByColumn;
begin
  Result := Insert(Count, Column);
end;


procedure TGroupByColumnList.Add(columnInfo: array of WideString);
begin
  insert(Count, ColumnInfo);
end;

function TGroupByColumnList.Add(Column: TGroupByColumn): TGroupByColumn;
begin
  Result := insert(Count, Column);
end;

function TGroupByColumnList.Insert(columnPos: Integer; const tableName,
  columnName : WideString): TGroupByColumn;
begin
  Result := TGroupByColumn.Create(Self);
  Result.Index := columnPos;
  Result.TableName := TableName;
  Result.ColumnName := ColumnName;
end;

function TGroupByColumnList.Insert(columnPos: Integer;
  const columnExpression: WideString): TGroupByColumn;
Var
  tmpTable, tmpName, tmpAlias : WideString;
begin
  ParseColumnInfo(columnExpression, tmpTable, tmpName, tmpAlias);
  Result := insert(columnPos, tmpTable, columnExpression);
end;

function TGroupByColumnList.Insert(columnPos : Integer; Column : TSelectColumn) : TGroupByColumn;
begin
  Result := Insert(columnPos, Column.TableName, Column.ColumnName);
end;

function TGroupByColumnList.Insert(Idx: Integer;
  Column: TGroupByColumn): TGroupByColumn;
begin
  InsertItem(Column, idx);
  Result := Column;
end;

procedure TGroupByColumnList.Insert(columnPos: Integer;
  columnInfo: array of WideString);
Var
  i : Integer;
  TableAlias, ColumnExpr, ColumnAlias : WideString;
begin
  for i := High(ColumnInfo) downto Low(ColumnInfo) do begin
    ParseColumnInfo(ColumnInfo[i], TableAlias, ColumnExpr, ColumnAlias);
    Insert(columnPos, TableAlias, ColumnExpr);
  end;
end;

{ TJoinTable }
constructor TJoinTable.Create(AOwner : TCollection);
begin
//  if (AOwner = nil) then
//    ShowMessage('TJoinTable: nil')
//  else
//    ShowMessage('TJoinTable: ' + AOwner.ClassName);
  inherited Create(AOwner);
  fJoinType := jtJoin;
end;

destructor TJoinTable.Destroy;
begin
  SafeFree(fJoinOnConditions);

  inherited;
end;

function TJoinTable.GetJoinOnConditions: TConditionList;
begin
  if (fJoinOnConditions = nil) then
    fJoinOnConditions := TConditionList.Create(Self);
    
  Result := fJoinOnConditions;
end;

procedure TJoinTable.SetJoinOnConditions(const Value : TConditionList);
begin
  if (Value <> fJoinOnConditions) then begin
    if (fJoinOnConditions <> nil) then
      SafeFree(fJoinOnConditions);

    fJoinOnConditions := Value;
  end;
end;


procedure TJoinTable.SetJoinType(value: TJoinType);
begin
  fJoinType := Value;
end;

procedure TJoinTable.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent : WideString = '');
begin
  InternalBuildJoinType(sql, indent);

  InternalBuildFromSource(sql, parameters, indent);

  InternalBuildOnLink(sql, parameters, indent);
end;

procedure TJoinTable.InternalBuildJoinType(sql : TWideStringBuffer; const indent : WideString);
begin
  if (joinType = jtLeftJoin) then
    sql.append('LEFT OUTER JOIN ')
  else
    sql.append('JOIN ');
end;

procedure TJoinTable.InternalBuildOnLink(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString);
begin
  if (Self.JoinOn.Count > 1) then begin
    sql.append(#13#10);
    sql.append(indent);
    sql.append(STD_INDENT);
    sql.append('  ');
  end;
  sql.append(' ON ');

  JoinOn.buildSQL(sql, parameters, indent + STD_INDENT);
end;

procedure TJoinTable.Assign(Source: TPersistent);
begin
  inherited;
  if (Source <> nil) and (Source is TJoinTable) then begin
    Self.JoinType := TJoinTable(Source).JoinType;
    Self.JoinOn.Assign(TJoinTable(Source).JoinOn);
  end;
end;

{ TJoinTableList }
constructor TJoinTableList.Create(AOwner : TPersistent);
begin
  inherited Create(AOwner, TJoinTable);
end;

function TJoinTableList.AddSubSelect(const joinToAlias : WideString; const joinOnCondition: WideString = ''; JoinType : TJoinType = jtJoin) : TJoinSubSelect;
begin
  Result := TJoinSubSelect(CreateJoinTable);
  //Result.SubSelect := subSelect;
  Result.TableAlias := joinToAlias;
  if (not IsEmpty(JoinOnCondition)) then
    Result.JoinOn.add(joinOnCondition);
  Result.JoinType := JoinType;
end;

function TJoinTableList.Add(subSelect: TSQLSelectFactory; const joinToAlias, joinOnCondition: WideString; JoinType : TJoinType = jtJoin): TJoinTable;
begin
  Result := CreateJoinTable;
  result.SubSelect := subSelect;
  Result.TableAlias := joinToAlias;
  if (not IsEmpty(JoinOnCondition)) then
    Result.JoinOn.add(joinOnCondition);
  Result.JoinType := JoinType;
end;

function TJoinTableList.Add(const joinTableExpression, joinOnCondition: WideString; JoinType : TJoinType = jtJoin): TJoinTable;
Var
  tmpSchema, tmpName, tmpAlias : WideString;
begin
  ParseColumnInfo(joinTableExpression, tmpSchema, tmpName, tmpAlias);
  Result := Add(tmpName, tmpAlias, joinOnCondition, JoinType);
end;

function TJoinTableList.Add(const joinTableName, joinToAlias, joinOnCondition : WideString; JoinType : TJoinType = jtJoin): TJoinTable;
begin
  Result := CreateJoinTable;
  result.TableName := joinTableName;
  Result.TableAlias := joinToAlias;
  if (not IsEmpty(joinOnCondition)) then
    Result.JoinOn.Add(joinOnCondition);
  Result.JoinType := joinType;
end;

procedure TJoinTableList.Add(joinToInfo: array of WideString; JoinType : TJoinType = jtJoin);
Var
  i, p : Integer;
  tmpTable, tmpAlias, tmpExpr : WideString;
begin
  for i := 0 to High(joinToInfo) do begin
    p := 1;
    tmpTable := ParseNext(p, joinToInfo[i], ', ', '"[]');
    tmpAlias := ParseNext(p, joinToInfo[i], ',', '"[]');
    tmpExpr := ParseNext(p, joinToInfo[i], ',', '"[]');
    if (tmpExpr = '') and (tmpAlias <> '') then begin
      tmpExpr := tmpAlias;
      tmpAlias := '';
    end;
    Add(tmpTable, tmpAlias, tmpExpr, joinType);
  end;
end;

function TJoinTableList.Add( JoinTable: TJoinTable): TJoinTable;
begin
  Result := JoinTable;
  InsertItem(Result);
end;

function TJoinTableList.GetJoinTable(Idx: Integer): TJoinTable;
begin
  Result := TJoinTable(GetItem(Idx));
end;

function TJoinTableList.GetJoinTableByAlias(const alias: WideString): TJoinTable;
Var
  i : Integer;
begin
  for i := 0 to Count - 1 do begin
    Result := GetJoinTable(i);
    if StringMatch(Result.TableAlias, Alias) then Exit;
  end;
  Result := nil;
end;

function TJoinTableList.CreateJoinTable : TJoinTable;
begin
  Result := TJoinTable.Create(self);
end;

procedure TJoinTableList.BuildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
Var
  i : Integer;
begin
  for i := 0 to count -1 do begin
    sql.append(#13#10);
    sql.append(indent);
    Self.GetJoinTable(i).buildSQL(sql, parameters, indent);
  end;
end;

{ TINSelectCondition }
constructor TINSelectCondition.Create(AOwner : TCollection);
begin
  inherited;

end;

constructor TINSelectCondition.Create(AOwner : TCollection; const ValueExpression: WideString;
  subSelect: TSQLSelectFactory);
begin
  Create(AOwner);
  Self.ValueExpression := ValueExpression;
  if(SubSelect <> nil) then
    Self.SubSelect.Assign(SubSelect);
end;

destructor TINSelectCondition.Destroy;
begin
  SafeFree(FSubSelect);
  inherited;
end;

function TINSelectCondition.GetSubSelect : TSQLSelectFactory;
begin
  if (fSubSelect = nil) then
    fSubSelect := InternalCreateSubSelect;

  Result := fSubSelect;
end;

function TINSelectCondition.InternalCreateSubSelect : TSQLSelectFactory;
begin
  Result := TSQLSelectFactory.Create(Self);
end;

procedure TINSelectCondition.SetSubSelect(const Value : TSQLSelectFactory);
begin
  if (fSubSelect <> nil) and (fSubSelect.GetOwner = Self) then
    SafeFree(fSubSelect);

  fSubSelect := Value;
end;

procedure TINSelectCondition.Assign(Other : TPersistent);
begin
  if (Other is TConditionGroup) then begin
    Self.ValueExpression := TInSelectCondition(Other).ValueExpression;
    Self.SubSelect.Assign(TInSelectCondition(Other).SubSelect);
  end;

  inherited Assign(Other);
end;


procedure TINSelectCondition.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  if (IsNegative) then
    sql.append('( NOT ');
  sql.append('(');
  sql.append(ValueExpression);
  sql.append(' IN ('#13#10);
  subSelect.buildSQL(sql, parameters, indent + STD_INDENT + STD_INDENT);
  sql.append(') )');
  if (IsNegative) then
    sql.append(')');
end;


function TINSelectCondition.GetDisplayName: String;
begin
  Result := '';
  if (ValueExpression <> '') then
    Result := ValueExpression;

  if (SubSelect <> nil) and (SubSelect.FromTable <> nil)
    and (SubSelect.FromTable.TableName <> '')then
  begin
    if (result = '') then
      Result := '<expr>';

    Result := Result + ' IN (SELECT FROM ' + SubSelect.FromTable.TableName + ')'
  end
  else if (Result <> '') then
    Result := Result + ' IN (<subSelect>)';

  if (Result = '') then
    Result := inherited GetDisplayName;
end;

{ TConditionListX }

function TConditionListX.AddInSelect(ValueExpression: WideString;
  subSelect: TSQLSelectFactory=nil): TINSelectCondition;
begin
  Result := TINSelectCondition.Create(Self, ValueExpression, subSelect);
end;


{ TSQLSelectFactory }
constructor TSQLSelectFactory.Create(AOwner : TPersistent=nil);
begin
  inherited Create(AOwner);
end;

destructor TSQLSelectFactory.Destroy;
begin
  SafeFree(fFromTable);
  SafeFree(fColumns);
  SafeFree(fJoinTos);
  SafeFree(fWhereClauses);
  SafeFree(fAdditionalConditions);
  SafeFree(fHavingClauses);
  SafeFree(fOrderBys);
  SafeFree(fGroupBys);
  inherited;
end;

function TSQLSelectFactory.Get_fromTable: TFromTable;
begin
  if (fFromTable = nil) then begin
    fFromTable := TFromTable.Create(nil);
  end;

  Result := fFromTable;
end;

procedure TSQLSelectFactory.Set_FromTable(const Value : TFromTable);
begin
  if (Value <> fFromTable) then begin
    if Assigned(fFromTable) then
      SafeFree(fFromTable);

    fFromTable := Value;
  end;
end;

function TSQLSelectFactory.Get_Columns: TSelectColumnList;
begin
  if (fColumns = nil) then
    fColumns := TSelectColumnList.Create(Self);

  Result := fColumns;
end;

function TSQLSelectFactory.Get_JoinTos: TJoinTableList;
begin
  if (fJoinTos = nil) then
    fJoinTos := TJoinTableList.Create(Self);

  result := fJoinTos;
end;

function TSQLSelectFactory.Get_WhereClauses: TConditionListX;
begin
  if (fWhereClauses = nil) then
    fWhereClauses := TConditionListX.Create(Self);

  Result := fWhereClauses;
end;

function TSQLSelectFactory.Get_AdditionalConditions : TConditionList;
begin
  if (fAdditionalConditions = nil) then
    fAdditionalConditions := TConditionList.Create(Self);

  Result := fAdditionalConditions;
end;

function TSQLSelectFactory.Get_HavingClauses: TConditionList;
begin
  if (fHavingClauses = nil) then
    fHavingClauses := TConditionList.Create(Self);

  Result := fHavingClauses;
end;

function TSQLSelectFactory.Get_Order: TOrderList;
begin
  if (fOrderBys = nil) then
    fOrderBys := TOrderList.Create(Self);

  Result := fOrderBys;
end;

function TSQLSelectFactory.Get_GroupBys: TGroupByColumnList;
begin
  if (fGroupBys = nil) then
    fGroupBys := TGroupByColumnList.Create(Self);

  Result := fGroupBys;
end;

function TSQLSelectFactory.Get_TopCount: Integer;
begin
  Result := fTopCount;
end;

procedure TSQLSelectFactory.Set_TopCount(const Value: Integer);
begin
  fTopCount := Value;
end;

function TSQLSelectFactory.Get_Distinct : Boolean;
begin
  Result := fDistinct;
end;

procedure TSQLSelectFactory.Set_Distinct(const Value : Boolean);
begin
  fDistinct := Value;
end;


procedure TSQLSelectFactory.Set_Columns(const Value : TSelectColumnList);
begin
  if (fColumns <> Value) then begin
    if (fColumns <> nil) then
      SafeFree(fColumns);

    fColumns := Value;
  end;
end;

procedure TSQLSelectFactory.Set_GroupBys(const Value: TGroupByColumnList);
begin
  if (fGroupBys <> Value) then begin
    if (fGroupBys <> nil) then
      SafeFree(fGroupBys);

    fGroupBys := Value;
  end;
end;

procedure TSQLSelectFactory.Set_HavingClauses(
  const Value: TConditionList);
begin
  if (fHavingClauses <> Value) then begin
    if (fHavingClauses <> nil) then
      SafeFree(fHavingClauses);

    fHavingClauses := Value;
  end;
end;

procedure TSQLSelectFactory.Set_JoinTos(const Value: TJoinTableList);
begin
  if (fJoinTos <> Value) then begin
    if (fJoinTos <> nil) then
      SafeFree(fJoinTos);

    fJoinTos := Value;
  end;
end;

procedure TSQLSelectFactory.Set_Order(const Value: TOrderList);
begin
  if (fOrderBys <> Value) then begin
    if (fOrderBys <> nil) then
      SafeFree(fOrderBys);

    fOrderBys := Value;
  end;
end;

procedure TSQLSelectFactory.Set_WhereClauses(const Value: TConditionListX);
begin
  if (fWhereClauses <> Value) then begin
    if (fWhereClauses <> nil) then
      SafeFree(fWhereClauses);

    fWhereClauses := Value;
  end;
end;

procedure TSQLSelectFactory.Set_AdditionalConditions(const Value: TConditionList);
begin
  AdditionalConditions.Clear;
  AdditionalConditions.Assign(Value);
end;



procedure TSQLSelectFactory.Clear;
begin
  FromTable := nil;
  Columns := nil;
  JoinTo := nil;
  Where := nil;
  AdditionalConditions.Clear;
  Having := nil;
  OrderBy := nil;
  GroupBy := nil;
  TopCount := 0;
  Distinct := False;
end;

procedure TSQLSelectFactory.buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = '');
begin
  sql.append(indent);
  sql.append('SELECT ');

  InternalBuildColumnList(sql, parameters, indent);

  InternalBuildFromClause(sql, parameters, indent);

  InternalBuildJoinClauses(sql, parameters, indent);

  InternalBuildWhereClause(sql, parameters, indent);

  InternalBuildGroupClause(sql, parameters, indent);

  InternalBuildHavingClause(sql, parameters, indent);

  InternalBuildOrderClause(sql, parameters, indent);
end;

procedure TSQLSelectFactory.InternalBuildColumnList(sql : TWideStringBuffer;
  parameters : TParameterList; const Indent : WideString);
begin
  if (Distinct) then
    sql.append('DISTINCT ');

  if (topCount > 0) then begin
    sql.append(' TOP ');
    sql.append(IntToStr(topCount));
    sql.append(' ');
  end;

  if (columns.Count > 0) then begin
    columns.buildSQL(sql, parameters, indent);
    sql.append(#13#10);
    sql.append(indent);
  end
  else
    sql.append('* ');
end;

procedure TSQLSelectFactory.InternalBuildFromClause(sql : TWideStringBuffer;
  parameters : TParameterList; const Indent : WideString);
begin
  sql.append(' FROM ');
  fromTable.buildSQL(sql, parameters, indent);
end;

procedure TSQLSelectFactory.InternalBuildJoinClauses(sql : TWideStringBuffer;
  parameters : TParameterList; const Indent : WideString);
begin
  if (joinTo.Count > 0) then
    JoinTo.buildSQL(sql, parameters, indent);
end;

procedure TSQLSelectFactory.InternalBuildWhereClause(sql : TWideStringBuffer;
  parameters : TParameterList; const Indent : WideString);
begin
  if (where.Count > 0) then begin
    sql.append(#13#10);
    sql.append(indent);
    sql.append('WHERE ');
    where.buildSQL(sql, parameters, indent);
  end;

  if (additionalConditions.Count > 0) then begin
    sql.append(#13#10);
    sql.append(indent);
    if (where.Count > 0) then
      sql.append('  AND ')
    else begin
      sql.append(#13#10);
      sql.append(indent);
      sql.append('WHERE ');
    end;
    additionalConditions.buildSQL(sql, parameters, indent);
  end;
end;

procedure TSQLSelectFactory.InternalBuildGroupClause(sql : TWideStringBuffer;
  parameters : TParameterList; const Indent : WideString);
begin
  if (groupBy.Count > 0) then begin
    sql.append(#13#10);
    sql.append(indent);
    sql.append('GROUP BY ');
    groupBy.buildSQL(sql, parameters, indent);
  end;
end;

procedure TSQLSelectFactory.InternalBuildHavingClause(sql : TWideStringBuffer;
  parameters : TParameterList; const Indent : WideString);
begin
  if (having.Count > 0) then begin
    sql.append(#13#10);
    sql.append(indent);
    sql.append('HAVING ');
    having.buildSQL(sql, parameters, indent);
  end;
end;

procedure TSQLSelectFactory.InternalBuildOrderClause(sql : TWideStringBuffer;
  parameters : TParameterList; const Indent : WideString);
begin
  if (orderBy.Count > 0) then begin
    sql.append(#13#10);
    sql.append(indent);
    sql.append('ORDER BY ');
    orderBy.buildSQL(sql, parameters, indent);
  end;
end;

function TSQLSelectFactory.prepareQuery(Connection : TPRADOConnection;
  ExecuteOptions : TExecuteOptions = [];
  Open : WordBool = true) : TPRADOQuery;
begin
  Result := TPRADOQuery.Create(nil);
  try
    Result.Connection := Connection;
    prepareQuery(Result, ExecuteOptions, Open);
  except
    SafeFreeAndNil(Result);
    raise;
  end;
end;

type TExposeCustomADODataset = class(TCustomADODataSet);

Var
  CopyToClipboard : Boolean = False;

procedure TSQLSelectFactory.prepareQuery(Query : TCustomADODataSet;
  ExecuteOptions : TExecuteOptions = [];
  Open : WordBool = true);
Var
  Parameters : TParameterList;
  sql : TWideStringBuffer;
  {$IFDEF PERFTIMER_SQLFACTORY}
  tmrSQLFactory : TTimerPack;
  {$ENDIF}
begin
  // DO NOT CHANGE THIS VALUE IN SOURCE
  // Use Evaluation Ctrl-F7 at run time to change
  //   the value stored in this variable
  CopyToClipboard := False; // Use Ctrl-F7 at runtime to change after it's set
  // DO NOT CHANGE THIS VALUE IN SOURCE
  // If you are changing the value in the source
  //  You are not understanding the purpose of it.
  If CopyToClipboard then // Use Ctrl-F7 at runtime to change after it's set
    Clipboard.AsText := self.AsString; // Includes parameters as comment

  Parameters := TParameterList.Create(Self);
  sql := TWideStringBuffer.Create;
  try
    if (Query.Active) then
      Query.Close;

    buildSQL(sql, Parameters, '');
    if (Query is TPRADOQuery) then
      TPRADOQuery(Query).SQL.Text := sql.ToString
    else
      TExposeCustomADODataset(Query).CommandText := sql.toString;

    Query.ExecuteOptions := ExecuteOptions;
    if (Parameters.Count > 0) then
      Parameters.CopyTo(TExposeCustomADODataset(Query).Parameters);
                             
    if (Open) and (Query.Connection <> nil) then begin
      {$IFDEF PERFTIMER_SQLFACTORY}
      tmrSQLFactory := GetTimerPack(Copy(sql.ToString, 1, 100));
      StartTimer(tmrSQLFactory, 0, '');
      {$ENDIF}
      try
        Query.Open;
      except on E : Exception do begin
        try
          sql.append(#13' parameters (');
          parameters.asString(sql);
          sql.append(')');
        except {ignore} end;
        raise Exception.create(E.ClassName + ':' + E.message +
                  #13'SQL: ' + sql.toString);
      end; end;
      {$IFDEF PERFTIMER_SQLFACTORY}
      CompleteTimer(tmrSQLFactory, 0);
      {$ENDIF}
    end;
  finally
    SafeFree(Parameters);
    SafeFree(sql);
  end;
end;

procedure TSQLSelectFactory.ParseSQL(const SQL: WideString);
begin
  Clear;
  SQLParser.ParseSQLSelect(SQL, Self);
end;

procedure TSQLSelectFactory.Assign(Source: TPersistent);
Var
  Other : TSQLSelectFactory;
begin
  inherited;
  if (Source <> nil) and (Source is TSQLSelectFactory) then begin
    Other := TSQLSelectFactory(Source);
    Self.FromTable.Assign(Other.FromTable);
    Self.TopCount := Other.TopCount;
    Self.Columns.Assign(Other.Columns);
    Self.JoinTo.Assign(Other.JoinTo);
    Self.Where.Assign(Other.Where);
    Self.AdditionalConditions.Assign(Other.AdditionalConditions);
    Self.Having.Assign(Other.Having);
    Self.OrderBy.Assign(Other.OrderBy);
    Self.GroupBy.Assign(Other.GroupBy);
  end;

end;

initialization
{$IFNDEF NOUNITVERSION}
  RegisterUnit('$Source: /Procurement2/shared/SQLFactorySelect.pas,v $', '$Revision: 1.28 $', '$Date: 2014/08/15 22:25:45 $');
{$ENDIF}
end.



