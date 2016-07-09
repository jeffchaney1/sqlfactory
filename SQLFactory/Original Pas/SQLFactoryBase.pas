{******************************************************************************
  Base classes for SQLFactory.
  &nbsp;
  Parent classes for all classes that are part of the SQLFactory library.
  @author Jeff Chaney
  @author Guardian Industries, Inc., Auburn Hills, MI
  @author Last Changed By: $Author: jchaney $ $Date: 2014/08/15 22:25:44 $
  @group Shared.SQLFactory
  @version $Id: SQLFactoryBase.pas,v 1.46 2014/08/15 22:25:44 jchaney Exp $
  @version
******************************************************************************}

unit SQLFactoryBase;

interface

{$I CompilerConfig.inc}

uses Classes, StringBuffer, CommonStringLib, TypedList, SysUtils, ADODB;

{$TYPEINFO ON}
type
  {******************************************************************************
    Base class for SQL Factory exceptions
    @group Exceptions
  ******************************************************************************}
  ESQLFactoryException = class(Exception) end;
  {******************************************************************************
    Exception thrown when buildSQL() is called on an UPDATE or DELETE factory
    when there are no conditions to limit the consequences.
    @see SQLFactoryModify.TSQLUpdateFactory
    @see SQLFactoryMoidfy.TSQLDeleteFactory
    @group Exceptions
  ******************************************************************************}
  ESQLUpdateNoConditions = class(ESQLFactoryException);
  {******************************************************************************
    Exception thrown by the UPDATE factory when no columns have been defined
    to be updated.
    @see SQLFactoryModify.TSQLUpdateFactory
    @group Exceptions
  ******************************************************************************}
  ESQLUpdateNoColumns = class(ESQLFactoryException);

//  TParameterType = (ftString, ftInteger, ftBoolean, ftDouble, ftDateTime, ftUnknown);
  {******************************************************************************
    Holds parameter information assigned to a TParameteredElement
    @see TParameteredElement
  ******************************************************************************}
  TParameter = class(TCollectionItem)
  private
    fValue : Variant;
    fDataType : TDataType;
    fDirection : TParameterDirection;
    fSize : Integer;
  protected
    procedure SetValue(const Value : Variant);
    procedure SetDataType(const Value : TDataType);
    procedure SetDirection(const Value : TParameterDirection);
    procedure SetSize(const Value : Integer);
  public
    procedure Assign(Source : TPersistent); override;
    property Value : Variant read fValue write SetValue;
    property DataType : TDataType read fDataType write SetDataType;
    property Direction : TParameterDirection read fDirection write SetDirection;
    property Size : Integer read fSize write SetSize;
  end;

  {******************************************************************************
    Holds a list of TParameter's
    &nbsp;
    Although the value stored in the actual TParameter is a Variant, this
    class has methods for assigning typed values to allow compile time checking
    as well as conversion.  The conversion is especially important for
    TDateTime values.  Normally when a TDateTime is passed in a Variant
    parameter it is converted to a varDouble not a varDateTime.
  ******************************************************************************}
  TParameterList = class(TOwnedCollection)
  protected
    {******************************************************************************
      Getter for Parameter property
      @group Getters
    ******************************************************************************}
    function GetItem(Index : Integer) : TParameter;
    {******************************************************************************
      Creates a TParameter object and adds it to the list.
      &nbsp;
      This method simply consolidates the logic that is used by the various
      add...Parameter() methods.
      @param Value The variant value to be stored in the parameter
      @param DataType The type of data this parameter represents in the SQL.
        Typically this is determined by the type of the Variant.
      @param Direction The TParameterDirection (pdInput, pdOutput, etc.)
      @return The TParameter created.
    ******************************************************************************}
    function CreateParameter(Value : Variant; DataType : TDataType; Size : Integer; Direction : TParameterDirection) : TParameter;
  public
    {******************************************************************************
      Constructor
      @param AOwner TParameterList decends from an TOwnedCollection so that it
        could be used on a component in the visual designer.  If the
        TParameterList is to be used as a property this value must be the
        parent object.
      @group Constuctor
    ******************************************************************************}
    constructor Create(AOwner : TPersistent = nil);
    {******************************************************************************
      Destructor
      @group Constuctor
    ******************************************************************************}
    destructor Destroy; override;

    {******************************************************************************
      Append the values in the source array to the list of parameters.
      &nbsp;
      All parameters are added as pdInput parameters.
      @param source The array of TVarRec values.
    ******************************************************************************}
    procedure addParameters(source : array of const); overload;
    {******************************************************************************
      Append the values in the source TParameterList to this list of parameters.
      &nbsp;
      Clones of the source TParameters are created.
      @param source The TParameterList that contains the values to be added
        to this TParameterList.
    ******************************************************************************}
    procedure addParameters(source : TParameterList); overload;
    {******************************************************************************
      Copy the parameters stored in this list to the TDataSet.Parameters
      &nbsp;
      The copy is performed on a positional basis.
      &nbsp(4);Parameter[0] goes to destination[0]
      &nbsp(4);Parameter[1] goes to destination[1]
      &nbsp(4);...
      If destination does not have enough positions, it's length is increased.
      @param destination The TDataSet.Parameters that will receive these
        parameters.
    ******************************************************************************}
    procedure copyTo(destination : TParameters);

    // Intermediate value is stored in a variant and Variant Reals
    //   are stored as Doubles.
    {******************************************************************************
      Append a TParameter with a varBoolean type and pdInput Direction
      @param value The boolean value to be stored.
    ******************************************************************************}
    procedure addBooleanParameter(value : Boolean);
    {******************************************************************************
      Append a TParameter with a varInteger type and pdInput Direction
      @param value The Integer value to be stored.
    ******************************************************************************}
    procedure addIntegerParameter(value : Int64);
    {******************************************************************************
      Append a TParameter with a varDouble type and pdInput Direction
      &nbsp;
      Extended values stored in a variant are converted to varDouble, so to
      avoid weird rounding problems and exceptions Double is used for the
      Float parameter
      @param value The Double value to be stored.
    ******************************************************************************}
    procedure addFloatParameter(value : Double);
    {******************************************************************************
      Append a TParameter with a varOleStr type and pdInput Direction
      @param value The Integer value to be stored.
    ******************************************************************************}
    procedure addStringParameter(const value : WideString);
    {******************************************************************************
      Append a TParameter with a varDate type and pdInput Direction
      @param value The TDateTime value to be stored.
    ******************************************************************************}
    procedure addDateTimeParameter(value : TDateTime);
    {******************************************************************************
      Append a TParameter with the given Variant type and pdInput Direction
      @param value The Variant value to be stored.
    ******************************************************************************}
    procedure addVariantParameter(value : OleVariant);
    {******************************************************************************
      Append a TParameter with a type converted from the TVarRec parameter
      and pdInput Direction
      @param value The Integer value to be stored.
    ******************************************************************************}
    procedure addVarRecParameter(value : TVarRec);
    {******************************************************************************
      Append the given TParameter object onto this list.
      &nbsp;
      The Collection property of the TParameter object is assigned to this list
      @param value The TParameter object to be added.
    ******************************************************************************}
    procedure addParameter(value : TParameter);

    {******************************************************************************
      The current list of TParameter objects
    ******************************************************************************}
    property Parameter[Index : Integer] : TParameter read GetItem; default;

    {******************************************************************************
      Returns the current values copied into a Variant array.
    ******************************************************************************}
    function asVariantArray : OleVariant;

    function AsString : WideString; overload;
    procedure AsString(sql : TWideStringBuffer); overload;

    procedure Assign(Source : TPersistent); override;
  end;

  {******************************************************************************
    All classes that can be used to produce SQL snippets must implement
    this inteface.
    @group Interfaces
  ******************************************************************************}
  ISQLElement = interface
    ['{B1C7D743-E144-454D-83B7-546935D02B43}']
    {******************************************************************************
      This is the workhorse of the SQL Factories
      &nbsp;
      The implmentation of this method in the SQL Elements will actually create
      the SQL statement snippets or concatenate snippets produced by other
      SQL Elements.
      @param sql The TWideStringBuffer that is being used to accumulate the SQL
        command.
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The string prefix to be appended to front of each line
        of the SQL command.  This is really only to make the final command
        look pretty.  By default the top level starts with an empty string
        and it is up to the buildSQL() implementations to append STD_INDENT
        to the indent it was given for each lower level SQL Element.
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); overload;
    {******************************************************************************
      Build the SQL stored in this part of the factory and return it as a string.
      &nbsp;
      Typically this will only be used in the top most objects of the SQL
      Factories.  It's basic implemenations in TSQLElementItem and
      TSQLElementParent simply create a TWideStringBuffer and call the buildSQL()
      above and return the contents of the TWideStringBuffer.
      @param parameters (Optional:nil) The TParameterList to be used to store the
        parameters.  If it is nil a local TParameterList is created and free'd
        before the method exits.  If Parameters are generated but the local
        TParameterList was used, an exception is thrown.
      @return A string containing the SQL Command
      @see TSQLElementItem
      @see TSQLElementParent
      @throws ESQLFactoryException
    ******************************************************************************}
    function buildSQL(parameters : TParameterList = nil) : WideString; overload;

    {******************************************************************************
      Build the SQL stored in this part of the factory and return it as a string.
      &nbsp;
      Typically this will only be used in the top most objects of the SQL
      Factories.  It's basic implemenations in TSQLElementItem and
      TSQLElementParent simply create a TWideStringBuffer and call the buildSQL()
      above and return the contents of the TWideStringBuffer.  The parameter values
      are appended to the end of the string.
      @return A string containing the SQL Command
      @see TSQLElementItem
      @see TSQLElementList
      @see TSQLElementParent
    ******************************************************************************}
    function AsString : WideString;
  end;

  TSQLElementList = class;

  {******************************************************************************
    A Basic implementation of ISQLElement
    &nbsp;
    This classes will be extended to implement all the pieces of a SQL command
    @decendant TParameteredElement
    @decendant TTable
    @decendant TColumn
    @decendant TCondition
  ******************************************************************************}
  TSQLElementItem = class(TCollectionItem, ISQLElement)
  private
    fObjectID : Integer;
    f_ClassName : String;

  protected
    {******************************************************************************
      Implementation of the IUnknown interface.
      @group IUnknown
    ******************************************************************************}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    {******************************************************************************
      Implementation of the IUnknown interface.
      &nbsp;
      These objects are not going to be reference counted so this is just a
      filler.
      @group IUnknown
    ******************************************************************************}
    function _AddRef: Integer; stdcall;
    {******************************************************************************
      Implementation of the IUnknown interface.
      &nbsp;
      These objects are not going to be reference counted so this is just a
      filler.
      @group IUnknown
    ******************************************************************************}
    function _Release: Integer; stdcall;

    {******************************************************************************
      Abstract filler for ISQLElement.buildSQL
      @see ISQLElement
      @group ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); overload; virtual; abstract;

    {******************************************************************************
      Returns true if the Key of this Item matches the key passed in.
      &nbsp;
      This is a trivial implementation that always return false.
      @param Key The string key to be matched.
      @return True if the key passed in matches the key for this item.
    ******************************************************************************}
    function Match(const Key : WideString) : Boolean; virtual;
  public
    {******************************************************************************
      Constructor
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TCollection); reintroduce;

    {******************************************************************************
      Generate the SQL stored in this SQL Element and return it as a string
      &nbsp;
      Typically this method will only be used in the top most objects of the SQL
      Factories.  This implementation will simply create a  TWideStringBuffer and
      call the buildSQL(TWideStringBuffer, TParameterList, String) and return the
      contents of the TWideStringBuffer.
      @param parameters (Optional:nil) The TParameterList to be used to store the
        parameters.  If it is nil a local TParameterList is created and free'd
        before the method exits.  If Parameters are generated but the local
        TParameterList was used, an exception is thrown.
      @return A string containing the SQL Command
      @group ISQLElement
    ******************************************************************************}
    function buildSQL(parameters : TParameterList = nil) : WideString; overload; virtual;

    {******************************************************************************
      Build the SQL stored in this part of the factory and return it as a string.
      &nbsp;
      Typically this will only be used in the top most objects of the SQL
      Factories.  This implemenation will simply create a TWideStringBuffer and
      TParameterList and then call buildSQL(TWideStringBuffer, TParameter, string)
      and return the contents of the TWideStringBuffer.  The parameter values
      are appended to the end of the string.
      @return A string containing the SQL Command
      @see TSQLElementItem
      @see TSQLElementParent
      @group ISQLElement
    ******************************************************************************}
    function AsString : WideString;

    {******************************************************************************
      Return a description of this TCollectionItem
      &nbsp;
      This method is used to describe TCollectionItems in the Designer.
      @return A string description based on this items parents and the SQL
        snippet it contains.
    ******************************************************************************}
    function GetDisplayName : String; override;

    procedure Assign(Source : TPersistent); override;

    property _ClassName : String read f_ClassName;
  end;

  TSQLElementItemClass = class of TSQLElementItem;

  {******************************************************************************
    A Basic implementation of ISQLElement that will hold multiple TSQLElements
    &nbsp;
    This classes will be extended to implement all the pieces of a SQL command
    @decendant TConditionList
    @decendant TCustomColumnList
  ******************************************************************************}
  TSQLElementList = class(TOwnedCollection, ISQLElement)
  private
    fObjectID : Integer;
    f_ClassName : String;

  protected
    {******************************************************************************
      Implementation of the IUnknown interface.
      @group IUnknown
    ******************************************************************************}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    {******************************************************************************
      Implementation of the IUnknown interface.
      &nbsp;
      These objects are not going to be reference counted so this is just a
      filler.
      @group IUnknown
    ******************************************************************************}
    function _AddRef: Integer; stdcall;
    {******************************************************************************
      Implementation of the IUnknown interface.
      &nbsp;
      These objects are not going to be reference counted so this is just a
      filler.
      @group IUnknown
    ******************************************************************************}
    function _Release: Integer; stdcall;
  protected
    {******************************************************************************
      Basic getter to access the list
      &nbsp;
      This method will be called by decendants of this class so they can expose
      their own type specific getter
      @param Key This variant value can either be a string key that is passed
        to the Match() method or an integer index into the collection.
      @group Getters
    ******************************************************************************}
    function _GetItem(Key : Variant) : TSQLElementItem;

    {******************************************************************************
      Abstract filler for ISQLElement.buildSQL
      @see ISQLElement
      @group ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); overload; virtual; abstract;
  public
    constructor Create(AOwner: TPersistent; ItemClass: TSQLElementItemClass);
    {******************************************************************************
      Inserts a TSQLElementItem into this collection
      @param Item (Optional:nil) The TSQLElementItem to be added to the collection.
        If Item is nil the Add method is called to create a new TCollectionItem.
      @param Index (Optional:High(Integer)) The position in the collection where
        this item should be added.  If Index is greater than the current number
        of elements in this list, the new Item is appended to the end.  If
        Index is less than 0, the new Item is inserted at position 0.
      @return The TSQLElementItem that was added to the collection.
    ******************************************************************************}
    function InsertItem(Item: TSQLElementItem; Index: Integer = High(Integer)): TSQLElementItem;

    {******************************************************************************
      Find the item in the collection with a matching key.
      @param Key The string key to be matched.
      @return The integer index of the item that matches the key, or -1 if
        no match is found.
      @see TSQLElementItem.match
    ******************************************************************************}
    function IndexOf(const Key : WideString) : Integer;
    {******************************************************************************
      Generate the SQL stored in this SQL Element and return it as a string
      &nbsp;
      Typically this method will only be used in the top most objects of the SQL
      Factories.  This implementation will simply create a  TWideStringBuffer and
      call the buildSQL(TWideStringBuffer, TParameterList, String) and return the
      contents of the TWideStringBuffer.
      @param parameters (Optional:nil) The TParameterList to be used to store the
        parameters.  If it is nil a local TParameterList is created and free'd
        before the method exits.  If Parameters are generated but the local
        TParameterList was used, an exception is thrown.
      @return A string containing the SQL Command
      @group ISQLElement
    ******************************************************************************}
    function buildSQL(parameters : TParameterList = nil) : WideString; overload;

    {******************************************************************************
      Build the SQL stored in this part of the factory and return it as a string.
      &nbsp;
      Typically this will only be used in the top most objects of the SQL
      Factories.  This implemenation will simply create a TWideStringBuffer and
      TParameterList and then call buildSQL(TWideStringBuffer, TParameter, string)
      and return the contents of the TWideStringBuffer.  The parameter values
      are appended to the end of the string.
      @return A string containing the SQL Command
      @see TSQLElementItem
      @see TSQLElementParent
      @group ISQLElement
    ******************************************************************************}
    function AsString : WideString;

    procedure Assign(Source : TPersistent); override;

    property _ClassName : String read f_ClassName;
  end;

  {******************************************************************************
    A Basic implementation of ISQLElement that will be a Parent
    &nbsp;
    These classes will assemble the various parts of a SQL statement into one
    comprehensive whole.
    @decendant TSQLSelectFactory
    @decendant TSQLUpdateFactory
    @decendant TSQLInsertFactory
    @decendant TSQLDeleteFactory
  ******************************************************************************}
  TSQLElementParent = class(TPersistent, ISQLElement)
  private
    fObjectID : Integer;
    f_ClassName : String;
    fOwner : TObject;
  protected
    {******************************************************************************
      Implementation of the IUnknown interface.
      @group IUnknown
    ******************************************************************************}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    {******************************************************************************
      Implementation of the IUnknown interface.
      &nbsp;
      These objects are not going to be reference counted so this is just a
      filler.
      @group IUnknown
    ******************************************************************************}
    function _AddRef: Integer; stdcall;
    {******************************************************************************
      Implementation of the IUnknown interface.
      &nbsp;
      These objects are not going to be reference counted so this is just a
      filler.
      @group IUnknown
    ******************************************************************************}
    function _Release: Integer; stdcall;

    {******************************************************************************
      Abstract filler for ISQLElement.buildSQL
      @see ISQLElement
      @group ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); overload; virtual; abstract;
  public
    {******************************************************************************
      Constructor
      @param AOwner (Optional:nil) This is the owner of this object. This will
        be the TForm or parent component.
      @group Constructors
      @see PRTable.TPRTable
    ******************************************************************************}
    constructor Create(AOwner : TPersistent=nil);
    {******************************************************************************
      Getter for Owner passed in constructor
      &nbsp;
      This will not actually be used in a property but it is still a getter. It
      is the extended implementation of the TPersistent.GetOwner.
      @group Getters
    ******************************************************************************}
    function GetOwner : TPersistent; override;
    {******************************************************************************
      Generate the SQL stored in this SQL Element and return it as a string
      &nbsp;
      Typically this method will only be used in the top most objects of the SQL
      Factories.  This implementation will simply create a  TWideStringBuffer and
      call the buildSQL(TWideStringBuffer, TParameterList, String) and return the
      contents of the TWideStringBuffer.
      @param parameters (Optional:nil) The TParameterList to be used to store the
        parameters.  If it is nil a local TParameterList is created and free'd
        before the method exits.  If Parameters are generated but the local
        TParameterList was used, an exception is thrown.
      @return A string containing the SQL Command
      @group ISQLElement
    ******************************************************************************}
    function buildSQL(parameters : TParameterList = nil) : WideString; overload; virtual;
    {******************************************************************************
      Build the SQL stored in this part of the factory and return it as a string.
      &nbsp;
      Typically this will only be used in the top most objects of the SQL
      Factories.  This implemenation will simply create a TWideStringBuffer and
      TParameterList and then call buildSQL(TWideStringBuffer, TParameter, string)
      and return the contents of the TWideStringBuffer.  The parameter values
      are appended to the end of the string.
      @return A string containing the SQL Command
      @see TSQLElementItem
      @see TSQLElementParent
      @group ISQLElement
    ******************************************************************************}
    function AsString : WideString;

    procedure Assign(Source : TPersistent); override;
  end;

  {******************************************************************************
    SQL Elements that can have parameter values assigned to them.
    @decendant TTable
    @decendant TCondition
  ******************************************************************************}
  TParameteredElement = class(TSQLElementItem)
  private
    fParameters : TParameterList;

  protected
    {******************************************************************************
      Getter for Parameters property
      @group Getters
    ******************************************************************************}
    function GetParameters : TParameterList;
    {******************************************************************************
      Setter for Parameters property
      @group Setters
    ******************************************************************************}
    procedure SetParameters(const Value : TParameterList);
    {******************************************************************************
      ADO to Delphi string conversion
      &nbsp;
      This function is used to clean up SQL strings so that colons are used for
      parameter markers rather than question marks.
      @param S The string to be converted.
      @return The converted string.
    ******************************************************************************}
    function CleanUp(const S : WideString) : WideString; virtual;

    {******************************************************************************
      Called by BuildSQL to add the parameters assigned to this element
      to the full parameter list.
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param parameters THe TParamaeterList to be added to.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildParameters(parameters: TParameterList);
  public
    {******************************************************************************
      Destructor
      @group Constructors
    ******************************************************************************}
    destructor Destroy; override;

    {******************************************************************************
      Add the values from an array of TVarRec's
      &nbsp;
      Passthrough to TParameterList.addParameters(array of const)
      @see TParameterList
    ******************************************************************************}
    procedure addParameters(parameters : array of const); overload;
    {******************************************************************************
      Add the values from a TParameterList
      &nbsp;
      Passthrough to TParameterList.addParameters(TParameterList)
      @see TParameterList
    ******************************************************************************}
    procedure addParameters(parameters : TParameterList); overload;

    // Intermediate value is stored in a variant and Variant Reals
    //   are stored as Doubles.
    {******************************************************************************
      Add a boolean parameter
      &nbsp;
      Passthrough to TParameterList.addBooleanParameter()
      @see TParameterList
    ******************************************************************************}
    procedure addBooleanParameter(value : Boolean);
    {******************************************************************************
      Add a Integer parameter
      &nbsp;
      Passthrough to TParameterList.addIntegerParameter()
      @see TParameterList
    ******************************************************************************}
    procedure addIntegerParameter(value : Int64);
    {******************************************************************************
      Add a Float parameter
      &nbsp;
      Passthrough to TParameterList.addFloatParameter()
      @see TParameterList
    ******************************************************************************}
    procedure addFloatParameter(value : Extended);
    {******************************************************************************
      Add a String parameter
      &nbsp;
      Passthrough to TParameterList.addStringParameter()
      @see TParameterList
    ******************************************************************************}
    procedure addStringParameter(const value : WideString);
    {******************************************************************************
      Add a DateTime parameter
      &nbsp;
      Passthrough to TParameterList.addStringDateTime
      @see TParameterList
    ******************************************************************************}
    procedure addDateTimeParameter(value : TDateTime);
    {******************************************************************************
      Add a Variant parameter
      &nbsp;
      Passthrough to TParameterList.addVariantingDateTime
      @see TParameterList
    ******************************************************************************}
    procedure addVariantParameter(Value : Variant);
    {******************************************************************************
      Add a VarRec parameter
      &nbsp;
      Passthrough to TParameterList.addVarRecingDateTime
      @see TParameterList
    ******************************************************************************}
    procedure addVarRecParameter(Value : TVarRec);

    {******************************************************************************
      BuildSQL() implementation to deal with parameters.
      &nbsp;
      Adds any parameters in this object to the TParameterList passed in.
      @group ISQLElement
      @see ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); override;

    procedure Assign(Source : TPersistent); override;
  published
    {******************************************************************************
      The list of parameters associated with this element.
    ******************************************************************************}
    property Parameters : TParameterList read GetParameters write SetParameters;
  end;

  {******************************************************************************
    Basic Table Definition
    @decendant TFromTable
  ******************************************************************************}
  TTable = class(TParameteredElement)
  private
//    fOwner : TPersistent;
//    fOwnerRedirect : TOwnedCollection;
    fServerName   : WideString;
    fDatabaseName : WideString;
    fTableSchema : WideString;
    fTableName : WideString;
    fTableAlias : WideString;
    fAddDelimiters : Boolean;
  protected
//    function GetOwner : TPersistent; override;
    {******************************************************************************
      Match tables on the TableAlias
      &nbsp;
      TTable implementation of function introduced in TSQLElementItem
      If TableAlias is empty, TableName is used.
      @param Key The table alias to check for match.
      @return True if the table alias matches.
      @see TSQLElementItem
    ******************************************************************************}
    function Match(const Key : WideString) : Boolean; override;
    {******************************************************************************
      Getter for ServerName property
      @group Getters
    ******************************************************************************}
    function GetServerName: WideString; virtual;
    {******************************************************************************
      Getter for DatabaseName property
      @group Getters
    ******************************************************************************}
    function GetDatabaseName: WideString; virtual;
    {******************************************************************************
      Getter for TableSchema property
      @group Getters
    ******************************************************************************}
    function GetTableSchema : WideString; virtual;
    {******************************************************************************
      Getter for TableName property
      @group Getters
    ******************************************************************************}
    function GetTableName : WideString; virtual;
    {******************************************************************************
      Getter for TableAlias property
      @group Getters
    ******************************************************************************}
    function GetTableAlias : WideString; virtual;

    {******************************************************************************
      Setter for ServerName property
      @group Setters
    ******************************************************************************}
    procedure SetServerName(const Value : WideString); virtual;
    {******************************************************************************
      Setter for DatabaseName property
      @group Setters
    ******************************************************************************}
    procedure SetDatabaseName(const Value : WideString); virtual;
    {******************************************************************************
      Setter for TableSchema property
      @group Setters
    ******************************************************************************}
    procedure SetTableSchema(const Value : WideString); virtual;
    {******************************************************************************
      Setter for TableName property
      &nbsp;
      This setter will parse a full Table expression into the schema, name and alias
      &nbsp(4)[Schema].[Name] [Alias]
      Schema can have multiple parts.  Name is the identifier before the space
      is delimited on the left by the last period or the start of the string.
      For example: [Procurement].[dbo].ADDRESS SupplierAddr would parse into
      &nbsp(4)Schema=[Procurement].[dbo]
      &nbsp(4);Name=ADDRESS
      &nbsp(4);Alias=SupplierAddr
      @group Setters
    ******************************************************************************}
    procedure SetTableName(const Value : WideString); virtual;
    {******************************************************************************
      Setter for TableAlias property
      @group Setters
    ******************************************************************************}
    procedure SetTableAlias(const Value : WideString); virtual;

    {******************************************************************************
      Called by BuildSQL to add the full table identifier to the sql buffer
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param sql The TWideStringBuffer containing the sql being built
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildFullTableIdentifier(sql: TWideStringBuffer; const indent : WideString);
    {******************************************************************************
      Called by BuildSQL to add the Server Name to the sql buffer
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param sql The TWideStringBuffer containing the sql being built
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildTableServer(sql: TWideStringBuffer; const indent : WideString);
    {******************************************************************************
      Called by BuildSQL to add the Database Name to the sql buffer
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param sql The TWideStringBuffer containing the sql being built
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildTableDatabase(sql: TWideStringBuffer; const indent : WideString);

    {******************************************************************************
      Called by BuildSQL to add the table schema to the sql buffer
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param sql The TWideStringBuffer containing the sql being built
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildTableSchema(sql: TWideStringBuffer; const indent : WideString);
    {******************************************************************************
      Called by BuildSQL to add the table name to the sql buffer
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param sql The TWideStringBuffer containing the sql being built
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildTableName(sql: TWideStringBuffer; const indent : WideString);
    {******************************************************************************
      Called by BuildSQL to add the table alias to the sql buffer
      &nbsp;
      This member was added so decendants could inherit functionality of the
      buildSQL without calling the inherited BuildSQL.
      @param sql The TWideStringBuffer containing the sql being built
      @param indent The current indention being used.
      @group Internal
      @see BuildSQL
    ******************************************************************************}
    procedure InternalBuildTableAlias(sql: TWideStringBuffer; const indent : WideString);


  public
    // I want the TTables to be owned but they will not usually be in a
    //  collection (TFromTable, TIntoTable - Not it Collection
    //  TJoinToTable - In Collection);
//    constructor Create(AOwner : TPersistent); reintroduce;

    {******************************************************************************
      Table implementation of ISQLElement buildSQL() workhorse method.
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
      Server the table is on (when using four-part naming
    ******************************************************************************}
    property ServerName   : WideString read GetServerName write SetServerName;
    {******************************************************************************
      Database the table is in (when using three or four-part naming
    ******************************************************************************}
    property DatabaseName : WideString read GetDatabaseName write SetDatabaseName;
    {******************************************************************************
      Database and Owner information of the table
    ******************************************************************************}
    property TableSchema : WideString read GetTableSchema write SetTableSchema;
    {******************************************************************************
      The actual TableName
    ******************************************************************************}
    property TableName : WideString read GetTableName Write SetTableName;
    {******************************************************************************
      The alias to be used to reference this table in this SQL statement
    ******************************************************************************}
    property TableAlias : WideString read GetTableAlias write SetTableAlias;
    {******************************************************************************
      Should the square-brackets delimit each section of the Table's full name.
    ******************************************************************************}
    property AddDelimiters : Boolean read fAddDelimiters write fAddDelimiters;
  end;

  {******************************************************************************
    Basic column definition
    &nbsp;
    This structure will simply deal with naming the column, not how the column
    is to be used.
    @decendant TFieldValueDef
  ******************************************************************************}
  TColumn = class(TParameteredElement)
  private
    fTableName : WideString;
    fColumnName : WideString;

    fAddDelimiters : Boolean;
  protected
    {******************************************************************************
      Getter for TableName property
      @group Getters
    ******************************************************************************}
    function GetTableName : WideString;
    {******************************************************************************
      Getter for ColumnName property
      @group Getters
    ******************************************************************************}
    function GetColumnName : WideString;
    {******************************************************************************
      Setter for TableName property
      @group Setters
    ******************************************************************************}
    procedure SetTableName(Const Value : WideString);
    {******************************************************************************
      Setter for ColumnName property
      &nbsp;
      This setter will parse a full column name expression into it's parts.
      &nbsp(4);[tablename].[columnname]
      Any alias information is dropped in this implementation
      @see ParseColumnInfo
      @group Setters
    ******************************************************************************}
    procedure SetColumnName(const Value : WideString);

    {******************************************************************************
      Matches on column name
      &nbsp;
      This is the TColumn implementation of the method introduced in
      TSQLElementItem.match()
      @param Str The Str to match to the column name
      @return True if this is a match.
      @see TSQLElementItem
    ******************************************************************************}
    function Match(const Str : WideString) : Boolean; override;

    {******************************************************************************
      The name of the table this column is found in.
      &nbsp;
      This property is not exposed in the basic TColumn because we are not
      sure if how it will be used will required the TableName
    ******************************************************************************}
    property TableName : WideString read GetTableName write SetTableName;

  public
    {******************************************************************************
      Column implementation of ISQLElement buildSQL() workhorse method.
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
      The column to be operated on or used.
      &nbsp;
      This value can be a simple expression rather than an actual column name.
    ******************************************************************************}
    property ColumnName : WideString read GetColumnName write SetColumnName;

    procedure Assign(Source : TPersistent); override;
  published
    {******************************************************************************
      Determines if square-brackets should be used to delimit the pieces of
      the columns name
    ******************************************************************************}
    property AddDelimiters : Boolean read fAddDelimiters write fAddDelimiters;
  end;

  {******************************************************************************
    A List of Columns
    &nbsp;
    @decendant TColumnList
  ******************************************************************************}
  TCustomColumnList = class(TSQLElementList)
  private
    fColumnsPerRow : Integer;
  protected
    {******************************************************************************
      Getter for Field property
      &nbsp;
      Type specific wrapper for _GetItem()
      @group Getters
    ******************************************************************************}
    function GetField(Key : Variant) : TColumn;
    {******************************************************************************
      Access to the TColumns in the list by column name or index
      &nbsp;
      This property is not exposed at this level.  Decendants will expose
      the property as needed.
      @param Key This variant value can either be a string key that is passed
        to the Match() method or an integer index into the collection.
    ******************************************************************************}
    property Field[Key : Variant] : TColumn read GetField; default;

  public
    constructor Create(AOwner: TPersistent; ItemClass: TSQLElementItemClass);

    {******************************************************************************
      TColumnList implementation of ISQLElement buildSQL() workhorse method.
      &nbsp;
      This implementation simply lists the columns in the list delimited by
      commas, ',', and it will break the list 4 per line.
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

    property ColumnsPerRow : Integer read fColumnsPerRow write fColumnsPerRow default 3;
  end;

  {******************************************************************************
    The implementation of a list of simple columns that will be exposed.
  ******************************************************************************}
  TColumnList = class(TCustomColumnList)
  public
    {******************************************************************************
      Constructor
      @param AOwner (Optional:nil) This is the owner of this object. This will
        be the TForm or parent component.
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TPersistent = nil);

    {******************************************************************************
      Type specific method to add a field to the list.
      @param Field The TColumn to be added to the end of the list.
    ******************************************************************************}
    procedure Add(Field : TColumn);

    {******************************************************************************
      Expose the Field propert defined in TCustomColumnList
      @see TCustomColumnList
    ******************************************************************************}
    property Field;
  end;

  {******************************************************************************
    A column that is to be assigned a value
    &nbsp;
    The value can be either a parameter or a literal value.
    @see SQLFactoryModify.TSQLModifyFactory
  ******************************************************************************}
  TFieldValueDef = class(TColumn)
  private
    fLiteralValue : OleVariant;
    fIsLiteral : Boolean;
    fUseRaw : Boolean;
    fMaxLength : Integer;
  protected
    {******************************************************************************
      Getter for LiteralValue property
      @group Getters
    ******************************************************************************}
    function getLiteralValue : Variant;
    {******************************************************************************
      Setter for LiteralValue property
      &nbsp;
      When a literal value is assigned any parameter values are cleared.
      @group Setters
    ******************************************************************************}
    procedure SetLiteralValue(Value : Variant);
    {******************************************************************************
      Getter for IsLiteral property
      @group Getters
    ******************************************************************************}
    function GetIsLiteral : WordBool;
    {******************************************************************************
      Getter for IsParameter property
      @group Getters
    ******************************************************************************}
    function GetIsParameter : WordBool;

    {******************************************************************************
      Getter for UseRaw property
      @group Getters
    ******************************************************************************}
    function GetUseRaw : WordBool;

    {******************************************************************************
      Setter for UseRaw property
      &nbsp;
      Indicates the literal value should be put into the SQL as is without quotes
      @group Setters
    ******************************************************************************}
    procedure SetUseRaw(Value : WordBool);

    {******************************************************************************
      Getter for MaxLength property
      @group Getters
    ******************************************************************************}
    function GetMaxLength : Integer;
    {******************************************************************************
      Setter for MaxLength property
      &nbsp;
      The maximum allowable length of a string value.  Ignored except for string
      values.
      @group Setters
    ******************************************************************************}
    procedure SetMaxLength(Value : Integer);
  public
    {******************************************************************************
      TFieldValue implementation of ISQLElement buildSQL() workhorse method.
      &nbsp;
      This implementation simply adds the ColumnName to the sql string.  The
      value is added by a call to buildValue().
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
      Append the value portion of this SQL element to the string buffer.
      &nbsp;
      The value being assigned to a column is not always used immediately
      following the columns name, such as how it is used in an INSERT VALUES
      command.  This implementation will add a parameter place holder if the
      value being assigned is a paramter or it will append the literal value.
      @param sql The TWideStringBuffer that is being used to accumulate the SQL
        command.
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
    ******************************************************************************}
    procedure BuildValue(sql : TWideStringBuffer; parameters : TParameterList);
    {******************************************************************************
      Clears the current literal value, making it unassigned
    ******************************************************************************}
    procedure ClearLiteral;

    {******************************************************************************
      The current Literal Value assigned to the column.
      &nbsp;
      This value is only used if IsParameter is false.
    ******************************************************************************}
    property LiteralValue : Variant read GetLiteralValue write SetLiteralValue;
    {******************************************************************************
      The name of the column to receive the value.
    ******************************************************************************}
    property ColumnName : WideString read GetColumnName write SetColumnName;
    {******************************************************************************
      Has a literal value been assigned to this column.
      &nbsp;
      If IsParameter is true the literal value will have no affect on the
      SQL that is produced.
    ******************************************************************************}
    property IsLiteral : WordBool read GetIsLiteral;

    {******************************************************************************
      Indicates the literal value should be put into the SQL as is without quotes
      &nbsp;
      IsLiteral must be true and there must be a string literal value assigned,
      before this value can be set to true.
      @group Setters
    ******************************************************************************}
    property UseRaw : WordBool read GetUseRaw write SetUseRaw;

    {******************************************************************************
      Have any parameter values been assigned to this column
      &nbsp;
      When a literal value is assigned any existing Parameters are cleared.
    ******************************************************************************}
    property IsParameter : WordBool read GetIsParameter;

    property MaxLength : Integer read GetMaxLength write SetMaxLength;

    procedure Assign(Source : TPersistent); override;
  end;

  {******************************************************************************
    A List of Field Values
    @see SQLFactoryModify.TSQLModifyFactory
  ******************************************************************************}
  TFieldValueList = class(TCustomColumnList)
  protected
    function GetSQLElementItemClass : TSQLElementItemClass; virtual;
    
    {******************************************************************************
      Getter for Column property
      &nbsp;
      This is simply a type specific wrapper for _GetItem() method in
      TCustomColumnList
      @param Key This variant value can either be a string key that is passed
        to the Match() method or an integer index into the collection.
      @group Getters
      @see TCustomColumnList
    ******************************************************************************}
    function GetColumn(Key : Variant) : TFieldValueDef;
    {******************************************************************************
      Add a column with a literal value to the end of the list.
      &nbsp;
      This is a consolidation method that the other add...Parameter() methods
      call.
      @param columnName The name of the column to receive the value.
      @parm literalValue The value to be assigned to this column
      @return The TFielValueDef that was added.
    ******************************************************************************}
    function AddVariant(const columnName : WideString; literalValue : OleVariant) : TFieldValueDef; overload;
    {******************************************************************************
      Insert a column into the list with a literal value at the specified index.
      &nbsp;
      This is a consolidation method that the other Insert...Parameter() methods
      call.
      @param columnPos The index at which this new column should be inserted.
      @param columnName The name of the column to receive the value.
      @parm literalValue The value to be assigned to this column
      @return The TFielValueDef that was added.
    ******************************************************************************}
    function InsertVariant(columnPos : Integer; const columnName : WideString; literalValue : OleVariant) : TFieldValueDef;

  public
    {******************************************************************************
      Constructor
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TPersistent = nil);
    {******************************************************************************
      The current list of columns
      &nbsp;
      @param Key This variant value can either be a string key that is passed
        to the Match() method or an integer index into the collection.
    ******************************************************************************}
    property Column[Key : Variant] : TFieldValueDef read GetColumn; default;

    {******************************************************************************
      Add the column to the end of the list.
      @param Column The TFieldValueDef to be added. If a nil value is passed
        an empty TFieldValueDef will be created and added.
      @return The TFieldValueDef that was added.
    ******************************************************************************}
    function Add(Column : TFieldValueDef) : TFieldValueDef; overload;
    {******************************************************************************
      Add a new TFieldValueDef with the given name
      &nbsp;
      Typically this version is used when the Parameter is going to be
      immediately assigned.
      &nbsp(4)Add('my column').AddStringParameter('my value');
      @param columnName The name of the column to be added.
      @return The TFieldValueDef that was added.
    ******************************************************************************}
    function Add(const columnName : WideString) : TFieldValueDef; overload;
    {******************************************************************************
      Assign the column a Boolean value
      @param columnName The column to be assigned.
      @param literalValue The boolean value to be assigned to the column.
      @return The TFieldValueDef added
    ******************************************************************************}
    function Add(const columnName : WideString; literalValue : Boolean) : TFieldValueDef; overload;
    {******************************************************************************
      Assign the column an Integer value
      @param columnName The column to be assigned.
      @param literalValue The Integer value to be assigned to the column.
      @return The TFieldValueDef added
    ******************************************************************************}
    function Add(const columnName : WideString; literalValue : Int64) : TFieldValueDef; overload;
    {******************************************************************************
      Assign the column a Float value
      @param columnName The column to be assigned.
      @param literalValue The Float value to be assigned to the column.
      @return The TFieldValueDef added
    ******************************************************************************}
    function Add(const columnName : WideString; literalValue : Extended) : TFieldValueDef; overload;
    {******************************************************************************
      Assign the column a String value
      @param columnName The column to be assigned.
      @param literalValue The String value to be assigned to the column.
      @param maxLength if value is greater than 0, only the MaxLen number of characters
      are used from the left side of the literal string.
      @return The TFieldValueDef added
    ******************************************************************************}
    function Add(const columnName : WideString; const literalValue : WideString; maxLength : Integer=-1) : TFieldValueDef; overload;
    {******************************************************************************
      Assign the column a TDateTime value
      @param columnName The column to be assigned.
      @param literalValue The TDateTime value to be assigned to the column.
      @return The TFieldValueDef added
    ******************************************************************************}
    function AddDateTime(const columnName : WideString; literalValue : TDateTime) : TFieldValueDef; overload;

    {******************************************************************************
      Add TFieldValueDef's assigning the column names from an array
      &nbsp;
      The columns that were added can then be access via the Column property
      @param columnNames The string array of column names
    ******************************************************************************}
    procedure Add(columnNames : array of Widestring); overload;
    {******************************************************************************
      Add the columns in the array to the list and immediately assign their
      literal values.
      @param columnNames The string array of columns names.
      @param literalValues The TVarRec array of values to be assigned to the
        columns.  The relationship between names and values is positional.
    ******************************************************************************}
    procedure Add(columnNames : array of Widestring; literalValues : array of const); overload;

    {******************************************************************************
      Insert the column at a specific position.
      @param ColumnPos The position within the list where the column is to be
        added.  If ColumnPos is less than 0, 0 is used.  If ColumnPos is greater
        than the number of items currently in the list, the new column is added
        to the end of the list.
      @param Column The TFieldValueDef to be added. If a nil value is passed
        an empty TFieldValueDef will be created and added.
      @return The TFieldValueDef that was added.
    ******************************************************************************}
    function Insert(columnPos : Integer; column : TFieldValueDef) : TFieldValueDef; overload;
    {******************************************************************************
      Insert a new TFieldValueDef with the given name at a specific position
      &nbsp;
      Typically this version is used when the Parameter is going to be
      immediately assigned.
      &nbsp(4);Insert(5,'my column').AddStringParameter('my value');
      @param columnPos The position in the list where the column should be
        inserted.
      @param columnName The name of the column to be added.
      @return The TFieldValueDef that was added.
    ******************************************************************************}
    function Insert(columnPos : Integer; const columnName : WideString) : TFieldValueDef; overload;
    {******************************************************************************
      Insert the column at a specific position and assign it a Boolean value
      @param ColumnPos The position in the list where the column should be
        inserted.
      @param columnName The column to be assigned.
      @param literalValue The boolean value to be assigned to the column.
      @return The TFieldValueDef added
    ******************************************************************************}
    function Insert(columnPos : Integer; const columnName : WideString; literalValue : Boolean) : TFieldValueDef; overload;
    {******************************************************************************
      Insert the column at a specific position and assign it a Integer value
      @param ColumnPos The position in the list where the column should be
        inserted.
      @param columnName The column to be assigned.
      @param literalValue The Integer value to be assigned to the column.
      @return The TFieldValueDef added
    ******************************************************************************}
    function Insert(columnPos : Integer; const columnName : WideString; literalValue : Int64) : TFieldValueDef; overload;
    {******************************************************************************
      Insert the column at a specific position and assign it a Float value
      @param ColumnPos The position in the list where the column should be
        inserted.
      @param columnName The column to be assigned.
      @param literalValue The Float value to be assigned to the column.
      @return The TFieldValueDef added
    ******************************************************************************}
    function Insert(columnPos : Integer; const columnName : WideString; literalValue : Extended) : TFieldValueDef; overload;
    {******************************************************************************
      Insert the column at a specific position and assign it a String value
      @param ColumnPos The position in the list where the column should be
        inserted.
      @param columnName The column to be assigned.
      @param literalValue The String value to be assigned to the column.
      @return The TFieldValueDef added
    ******************************************************************************}
    function Insert(columnPos : Integer; const columnName : WideString; const literalValue : WideString) : TFieldValueDef; overload;
    {******************************************************************************
      Insert the column at a specific position and assign it a TDateTime value
      @param ColumnPos The position in the list where the column should be
        inserted.
      @param columnName The column to be assigned.
      @param literalValue The TDateTime value to be assigned to the column.
      @return The TFieldValueDef added
    ******************************************************************************}
    function InsertDateTime(columnPos : Integer; const columnName : WideString; literalValue : TDateTime) : TFieldValueDef; overload;

    {******************************************************************************
      Insert TFieldValueDef's starting at the specific position and assign the
      column names from an array
      &nbsp;
      The columns that were added can then be access via the Column property
      @param columnPos The index of the first column to be added.
      @param columnNames The string array of column names
    ******************************************************************************}
    procedure Insert(columnPos : Integer; columnNames : array of WideString); overload;
    {******************************************************************************
      Insert the columns in the array to the list and immediately assign their
      literal values.
      @param columnPos The index of the first column to be added.
      @param columnNames The string array of columns names.
      @param literalValues The TVarRec array of values to be assigned to the
        columns.  The relationship between names and values is positional.
    ******************************************************************************}
    procedure Insert(columnPos : Integer; columnNames : array of WideString; literalValues : array of const); overload;

    {******************************************************************************
      Remove a column from the list
      &nbsp;
      If the column is not found, nothing happens.
      @param columnName The name of the column to be removed. The column is
        found using the Match() method of TSQLElementItem
      @see TSQLElementItem
    ******************************************************************************}
    procedure RemoveColumn(const columnName : WideString);

    {******************************************************************************
      This method is called by the TSQLInsertFactory to add the VALUE ()
      clause onto the INSERT command
      @param sql The TWideStringBuffer that is being used to accumulate the SQL
        command.
      @param parameters The TParameterList being accumulated with the parameter
        that were defined in each SQL Element.
      @param indent The string prefix to be appended to front of each line
        of the SQL command.  This is really only to make the final command
        look pretty.  By default the top level starts with an empty string
        and it is up to the buildSQL() implementations to append STD_INDENT
        to the indent it was given for each lower level SQL Element.
      @return True if the VALUES() clause was added.
      @see ISQLElement
      @see SQLFactoryModify.TSQLInsertFactory
    ******************************************************************************}
    function BuildValuesList(sql : TWideStringBuffer; parameters : TParameterList; const Indent : WideString) : Boolean;
  end;

  {******************************************************************************
    Operators that can be used to link conditions.
  ******************************************************************************}
  TConditionLinkOperator = (loAND, loOR);
  TConditionList = class;
  TConditionClass = class of TCondition;

  {******************************************************************************
    Base class for all Conditions used in the SQL Factories
    @decendant TSimpleCondition
    @decendant TGroupCondition
    @decendant SQLFactorySelect.TINCondition
  ******************************************************************************}
  TCondition = class(TParameteredElement)
  private
    fLinkOperator : TConditionLinkOperator;
    fIsNegative : Boolean;
  public
    {******************************************************************************
      Constructor
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TCollection);
    {******************************************************************************
      Assign the values of the other TCondition to this TCondition.
      @param Other The other TCondition whose values are to be copied to this
        TCondition.  If other is not a TCondition the inherited Assign() is
        called which will probably throw an EConvertError.
      @throws EConvertError
    ******************************************************************************}
    procedure Assign(Other : TPersistent); override;
  published
    {******************************************************************************
      How is this condition linked to the one before it.
      &nbsp;
      The LinkOperator of the first condition in a list is ignored.
    ******************************************************************************}
    property LinkOperator : TConditionLinkOperator read fLinkOperator write fLinkOperator default loAND;
    {******************************************************************************
      Is the NOT operator to be prepended to this condition.
    ******************************************************************************}
    property IsNegative : Boolean read fIsNegative write fIsNegative;

  end;

  {******************************************************************************
    A simple expession condition
  ******************************************************************************}
  TSimpleCondition = class(TCondition)
  private
    fExpression : WideString;
    fLiteralValue : Variant;
    fUseRaw : Boolean;
  protected
    {******************************************************************************
      Setter for Expression property
      @group Setters
    ******************************************************************************}
    procedure SetExpression(const Value : WideString); virtual;
    {******************************************************************************
      Getter for Expression property
      @group Getters
    ******************************************************************************}
    function GetExpression : WideString; virtual;

    {******************************************************************************
      Compares the Key to the expression in a caseless manner.
      @param Key The string to be compared to the expression in this condition.
      @return True if the Key matches the expression.
    ******************************************************************************}
    function Match(const Key : WideString) : Boolean; override;

    function GetUseRaw : Boolean;
    procedure SetUseRaw(Value : Boolean);
  public
    {******************************************************************************
      Constructor
      @param AOwner The TConditionList that will hold this Condition.
    ******************************************************************************}
    constructor Create(AOwner : TCollection); overload;
    {******************************************************************************
      Constructor
      @param AOwner The TConditionList that will hold this Condition.
      @param Expression The expression that is to be assigned to this Condition
      @param LinkOperator (Optional:loAnd) How is this expression to be linked
        to the condition before it in the list.
    ******************************************************************************}
    constructor Create(AOwner : TCollection; const Expression : WideString;
                      LinkOperator : TConditionLinkOperator = loAND); overload;

    {******************************************************************************
      Assign the values of the other TSimpleCondition to this TSimpleCondition.
      @param Other The other TSimpleCondition whose values are to be copied to
        this TSimpleCondition.  The inherited Assign() is also called.
      @throws EConvertError
    ******************************************************************************}
    procedure Assign(Other : TPersistent); override;

    {******************************************************************************
      TSimpleCondition implementation of ISQLElement buildSQL() workhorse method.
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

    function GetHasLiteralValue : WordBool;
    function GetLiteralValueAsText : WideString;

    property HasLiteralValue : WordBool read GetHasLiteralValue;
    property LiteralValueAsText : WideString read GetLiteralValueAsText;
    property UseRaw : Boolean read GetUseRaw write SetUseRaw;
  published
    {******************************************************************************
      The SQL Conditional expression
    ******************************************************************************}
    property Expression : WideString read GetExpression write SetExpression;

    property LiteralValue : Variant read fLiteralValue write fLiteralvalue;
  end;

  {******************************************************************************
    Stores a group of conditions that should be treated as a set.
    &nbsp;
    The typical use of this for adding a list of conditions grouped by OR in a
    condition list that uses AND
    &nbsp(4);(COLOR = 'Red') AND <STRONG>((SIZE > 10) OR (SIZE < 0))</STRONG> AND (Name Like '%this')
    &nbsp(4);&nbsp(28);^--- Condition Group -------^
  ******************************************************************************}
  TConditionGroup = class(TCondition)
  private
    fConditions : TConditionList;
  protected
    {******************************************************************************
      Getter for Conditions property
      @group Getters
    ******************************************************************************}
    function GetConditions : TConditionList;
  public
    {******************************************************************************
      Constructor
      @param AOwner This will most likely be the TConditionList that holds this
        TCondition
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TCollection); overload;
    {******************************************************************************
      Constructor
      @param AOwner This will most likely be the TConditionList that holds this
        TCondition
      @param DefaultLink The DefaultLink value used in the TConditionList
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TCollection; DefaultLink : TConditionLinkOperator); overload;
    {******************************************************************************
      Constructor
      @param AOwner This will most likely be the TConditionList that holds this
        TCondition
      @param Conditions A string array of conditional expressions that will be
        automatically added to the TConditionGroup as TSimpleConditions
      @param DefaultLink (Optional: loOR) The DefaultLink value used in the
        TConditionList
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TCollection; conditions : array of WideString; DefaultLink : TConditionLinkOperator = loOR); overload;
    {******************************************************************************
      Destructor
      @group Constructors
    ******************************************************************************}
    destructor Destroy; override;

    {******************************************************************************
      Assign the values of the other TConditionGroup to this TConditionGroup.
      @param Other The other TConditionGroup whose values are to be copied to
        this TConditionGroup.  The inherited Assign() is also called.
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
      TConditionGroup implementation of ISQLElement buildSQL() workhorse method.
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
  published
    {******************************************************************************
      The list of conditions in this group
    ******************************************************************************}
    property Conditions : TConditionList read GetConditions;
  end;

  {******************************************************************************
    Holds a (Value) IN [(Value List)] type of condition
  ******************************************************************************}
  TINListCondition = class(TCondition)
  private
    fValueExpression : WideString;
    fValues : TStringList;
    fAddQuotes : Boolean;
  protected
    {******************************************************************************
      Getter for Values property
      @group Getters
    ******************************************************************************}
    function GetValues : TStringList;
    {******************************************************************************
      Setter for Values property
      @group Setters
    ******************************************************************************}
    procedure SetValues(const Value : TStringList);
  public
    {******************************************************************************
      Constructor
      @param AOwner This will most likely be the TConditionList that holds this
        TCondition
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TCollection); overload;
    {******************************************************************************
      Constructor
      @param AOwner This will most likely be the TConditionList that holds this
        TCondition
      @param ValueExpression The string expression that is to be searched for
      @param RawValues A string array of values to be searched.  These values
        must be delimited as they would need to be in the SQL Statement.
        i.e. Strings must be quoted within the actual delphi string, '''Value''';
        &nbsp(5);Numerics are passed as strings but do not need quotes within the
        &nbsp(5);values, '123.45'
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TCollection; const ValueExpression: WideString; RawValues : array of WideString); overload;
    {******************************************************************************
      Destructor
      @group Constructors
    ******************************************************************************}
    destructor Destroy; override;

    {******************************************************************************
      Assign the values of the other TINConditionGroup to this TINConditionGroup.
      @param Other The other TINConditionGroup whose values are to be copied to
        this TINConditionGroup.  The inherited Assign() is also called.
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
      Setter for Values property
      &nbsp;
      This method is not actually tied to a property but it used to set the values.
      @param RawValues A string array of values to be searched.  These values
        must be delimited as they would need to be in the SQL Statement.
        i.e. Strings must be quoted within the actual delphi string, '''Value''';
        &nbsp(5);Numerics are passed as strings but do not need quotes within the
        &nbsp(5);values, '123.45'
      @group Setters
    ******************************************************************************}
    procedure SetRawValues(RawValues : array of WideString);
    {******************************************************************************
      Setter for Values property
      &nbsp;
      This method is not actually tied to a property but it used to set the values.
      @param StringValues An array of WideString values to be searched.  When this
        method is used, you do not need to add extra quotes to the values.
        'Value' is sufficient.
      @group Setters
    ******************************************************************************}
    procedure SetStringValues(StringValues : array of WideString); overload;

//    procedure SetStringValues(StringValues : TWideStringList); overload;
    procedure SetStringValues(StringValues : TStrings); overload;
    {******************************************************************************
      Setter for Values property
      &nbsp;
      This method is not actually tied to a property but it used to set the values.
      @param IntegerValues An array of integers.  Do not use any quotes to
        use this method.
      @group Setters
    ******************************************************************************}
    procedure SetIntegerValues(IntegerValues : array of Integer);
    {******************************************************************************
      Setter for Values property
      &nbsp;
      This method is not actually tied to a property but it used to set the values.
      @param FloatValues An array of integers.  Do not use any quotes to
        use this method.
      @group Setters
    ******************************************************************************}
    procedure SetFloatValues(FloatValues : array of Double; Precision : Integer = 17; Decimals : Integer = 4);

    {******************************************************************************
      TINCondition implementation of ISQLElement buildSQL() workhorse method.
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
      The string expression that is to be searched for
    ******************************************************************************}
    property ValueExpression : WideString read fValueExpression write fValueExpression;

    {******************************************************************************
      The values to be searched.
      &nbsp;
      The values are stored in their Raw format. i.e. Strings are quoted within
      the actual delphi string, '''Value''';
    ******************************************************************************}
    property Values : TStringList read GetValues write SetValues;

    property AddQuotes : Boolean read fAddQuotes write fAddQuotes;
  end;

  {******************************************************************************
    A List of conditions
  ******************************************************************************}
  TConditionList = class(TSQLElementList)
  private
    fDefaultLink : TConditionLinkOperator;
  protected
    {******************************************************************************
      Getter for Condition property
      @group Getters
    ******************************************************************************}
    function GetCondition(Idx : Integer) : TCondition;
    {******************************************************************************
      The link operator that is used when adding a Condition without a
      LinkOperator
    ******************************************************************************}
    property DefaultLink : TConditionLinkOperator read fDefaultLink write fDefaultLink default loAND;
  public
    {******************************************************************************
      Constructor
      @param AOwner (Optional:nil) This will be the SQL Factory will control the
        life of this object.
      @group Constructor
    ******************************************************************************}
    constructor Create(AOwner : TPersistent = nil); overload;
    {******************************************************************************
      Constructor
      @param AOwner (Optional:nil) This will be the SQL Factory will control the
        life of this object.
      @param DefaultLink This is the initial value of the DefaultLink property.
      @group Constructor
    ******************************************************************************}
    constructor Create(AOwner : TPersistent; DefaultLink : TConditionLinkOperator); overload;

    {******************************************************************************
      Assign the values of the other TConditionList to this object.
      @param Other The other TConditionList whose values are to be copied to
        this object.  If the other object is not a TConditinoList, the inherited
        Assign() is also called.
      @throws EConvertError
    ******************************************************************************}
    procedure Assign(Other : TPersistent); override;

    {******************************************************************************
      Add a condition to this collection
      @param Condition The TCondition to be added to this list.  If this
        parameter is passed as nil an TCondition is created and added.
      @return The TCondition added.
    ******************************************************************************}
    function Add(Condition : TCondition) : TCondition; overload;
    {******************************************************************************
      Add a TSimpleCondition with the specified conditional expression
      @param expression The conditional expression to be used to initialize
        the TSimpleCondition
      @return The TSimpleCondition that was added.
    ******************************************************************************}
    function Add(const expression: WideString): TSimpleCondition; overload; virtual;
    {******************************************************************************
      Add a TSimpleCondition with the specified conditional expression
      @param expression The conditional expression to be used to initialize
        the TSimpleCondition
      @param LinkOperator The TConditionalLinkOperator used to initialize the
        LinkOperator of the TSimpleConditions
      @return The TSimpleCondition that was added.
    ******************************************************************************}
    function Add(const expression: WideString; LinkOperator : TConditionLinkOperator): TSimpleCondition; overload; virtual;

    {******************************************************************************
      Adds multiple TSimpleConditions with the specified conditional expressions
      @param conditions The string array of conditional expressions to be used
        to initialize the TSimpleConditions.
    ******************************************************************************}
    procedure Add(conditions: array of WideString); overload; virtual;
    {******************************************************************************
      Adds multiple TSimpleConditions with the specified conditional expressions
      @param conditions The string array of conditional expressions to be used
        to initialize the TSimpleConditions.
      @param LinkOperator The TConditionalLinkOperator used to initialize the
        LinkOperator of all TSimpleConditions
    ******************************************************************************}
    procedure Add(conditions: array of WideString; LinkOperator : TConditionLinkOperator); overload; virtual;

    function AddGroup(LinkOperator : TConditionLinkOperator) : TConditionGroup; overload;
    function AddGroup(conditions: array of WideString; LinkOperator : TConditionLinkOperator = loOR) : TConditionGroup; overload; virtual; 

    function AddInList(ValueExpression : WideString; RawValues : array of WideString ) : TInListCondition; overload; virtual;

    function AddInList(ValueExpression : WideString; RawValues : TStringList) : TInListCondition; overload; virtual;

    {******************************************************************************
      Adds conditions for the specific key values passed.
      &nbsp;
      The implementation of this method simply calls the other AddParameterized()
      after translating the field parameter to a Variant Array.
      @param Fields The string array of key field names
      @param Values A Variant array of values that are the key to finding a
        specific row.
    ******************************************************************************}
    procedure AddParameterized(Fields : array of WideString; Values : Variant); overload; virtual;
    {******************************************************************************
      Adds conditions to for the specific key values passed.
      &nbsp;

      @param Fields The string array of key field names
      @param Values A Variant array of values that are the key to finding a
        specific row.
    ******************************************************************************}
    procedure AddParameterized(Fields : Variant; Values : Variant); overload; virtual;


    {******************************************************************************
      TConditionList implementation of ISQLElement buildSQL() workhorse method.
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
      The conditions that have been added to this list.
    ******************************************************************************}
    property Condition[Idx : Integer] : TCondition read GetCondition; default;
  end;


const
  /// Standard Indent
  STD_INDENT = '    ';
//  DigitCharacters : TASCIIWideCharacterSet = [WideChar('0')..WideChar('9')];
//  AlphaCharacters : TASCIIWideCharacterSet = [WideChar('a')..WideChar('z')
//                                    ,WideChar('A')..WideChar('Z')];
//  IdentifierBodyCharacters : TASCIIWideCharacterSet =
//                                    [WideChar('0')..WideChar('9')
//                                    ,WideChar('a')..WideChar('z')
//                                    ,WideChar('A')..WideChar('Z')
//                                    ,WideChar('_')];
  IdentifierBodyCharacters: TCharacterSet = ['0'..'9','A'..'Z','a'..'z', '_'];

{******************************************************************************
  Parse as string into the parts of a column definition
  &nbsp;
  Everything following the last space is considered the alias.
  AS is dropped if it exists.
  Everything up to the last period, '.', is assigned to the TableAlias
  The rest is the ColumnExpression
  For Example: Parse [Procurement].[dbo].ADDRESS.NAME AS SupplierName would give
  &nbsp(4);TableAlias=[Procurement].[dbo].ADDRESS
  &nbsp(4);ColumnExpression=NAME
  &nbsp(4);ColumnsAlias=SupplierName
  @param columnInfo The string to be parsed
  @param TableAlias (Output) The string to contain the Table information
  @param ColumnExpression (Output) The string to contain the column Name
  @param ColumnAlias (Output) The string to contain the column alias.
******************************************************************************}
procedure ParseColumnInfo(const columnInfo : WideString; Var tableAlias, columnExpression, columnAlias : WideString);
{******************************************************************************
  Determines if a string is an identifier
  @param Value The string to be evaluated.
  @return True if the value only contains Letters, Numbers and Underscores.
******************************************************************************}
function IsIdentifier(const Value : WideString) : Boolean;

{******************************************************************************
  Return the string name of a TConditionLinkOperator
  @param Link The TConditionLinkOperator to be named.
  @return The string name of the TConditionLinkOperator.
******************************************************************************}
function LinkOperatorToCode(link : TConditionLinkOperator) : WideString;
{******************************************************************************
  Return the TConditionLinkOperator with the specified name
  @param Code The name of a TConditionLinkOperator
  @return A TConditionLinkOperator that matches the code passed in. If no match
    is found the loAND is returned.
******************************************************************************}
function CodeToLinkOperator(const code : WideString) : TConditionLinkOperator;


{******************************************************************************
  Converts a numeric value to a string that can be used directly in a SQL statement.
  Specifically it makes sure the decimal separator is a period rather than
  a comma as is used in some countries.
  @param Value The Extended value to be converted.
  @return A string representation of the numeric value so it can be used in a
    SQL statement.
******************************************************************************}
function ConvertFloatToSQLLiteral(Value : Extended) : WideString;

{******************************************************************************
  Converts a TVarRec (const array parameter) value to a string that can be used
  directly in a SQL statement.
  @param Value The TVarRec to be converted.
  @return A string representation of the Variant value so it can be used in a
    SQL statement.
******************************************************************************}
function VarRecToLiteralValue(const VarRec : TVarRec) : WideString;

{******************************************************************************
  Converts a variant value to a string that can be used directly in a
  SQL statement.
  @param Value The Variant value to be converted.
  @return A string representation of the Variant value so it can be used in a
    SQL statement.
******************************************************************************}
function VarToLiteralValue(Value : Variant) : WideString;



implementation

uses UnitVersion, Math,  CommonObjLib, Variants, CommonVariantLib, DB, StrUtils,
  Windows;

Var
  _ObjectID : Integer;
function GetNextObjectID : Integer;
begin
  inc(_ObjectID);
  Result := _ObjectID;
end;

//procedure ParseColumnInfo(columnInfo: WideString;
//  var tableAlias, columnExpression, columnAlias: WideString);
//Var
//  p, last : Integer;
//  tmp : WideString;
//begin
//  p := Length(columnInfo);
//
//  if (p > 0) and (columnInfo[p] = ']') then
//    dec(p);
//  while (p > 0) and (columnInfo[p] in ['a'..'z', 'A'..'Z', '0'..'9', '_']) do begin
//    dec(p);
//  end;
//  if (p > 0) and (columnInfo[p] = '[') then
//    dec(p);
//  if (p > 0) and (columnInfo[p] = ' ') then begin
//    columnAlias := Copy(columnInfo, p + 1, Length(columnInfo));
//    setLength(columnInfo, p-1);
//    if (StringMatch(RightStr(columnInfo, 3), ' AS')) then
//      SetLength(columnInfo, p-4);
//  end
//  else
//    columnAlias := '';
//
//  p := 1;
//  tableAlias := ParseNext(p, columnInfo, '.', '"''', '[]()');
//  if (p >= length(columnInfo)) then begin
//    tableAlias := '';
//    p := 1;
//  end
//  else begin
//    last := p;
//    while (p < length(columnInfo)) do begin
//      last := p;
//      tmp := ParseNext(p, columnInfo, '.', '"''', '[]()');
//      if (p < length(columnInfo)) then
//        tableAlias := tableAlias + '.' + tmp;
//    end;
//    p := last;
//  end;
//  ColumnExpression := Copy(columnInfo, p, Length(ColumnInfo));
//end;

procedure ParseColumnInfo(const columnInfo: WideString;
  var tableAlias, columnExpression, columnAlias: WideString);
Var
  p : Integer;
  cleaned, tmp : WideString;
const
  Lower127  : TCharacterSet = [' '..#127];
begin
  cleaned := Trim(charOnly(Lower127, columnInfo));
  p := Length(columnInfo);

  columnAlias := ParsePrev(p, cleaned, ' ', '"', '()');
  if (p > 1) then begin
    columnAlias := RemoveBrackets('[', columnAlias, ']');
    if (columnAlias = CharOnly(IdentifierBodyCharacters, columnAlias)) then begin
      cleaned := Copy(cleaned, 1, p);
      tmp := ParsePrev(p, cleaned, ' ', '"', '');
      if StringMatch(tmp, 'AS') then
        cleaned := Copy(cleaned, 1, p);
    end
    else begin
      columnAlias := '';
    end;
  end
  else {there was no alias delimited by a space} begin
    columnAlias := '';
  end;
  p := 1;
  columnExpression := ParseNext(p, cleaned, '.', '"''', '[]()');
  tableAlias := '';
  while (p <= Length(cleaned)) do begin
    tableAlias := tableAlias + columnExpression;
    columnExpression := ParseNext(p, cleaned, '.', '"''', '[]()');
  end;
end;

function IsIdentifier(const Value : WideString) : Boolean;
Var
  p : Integer;
begin
  Result := True;
  for p := 1 to Length(Value) do
    if (not InCharSet(Value[p], IdentifierBodyCharacters)) then begin
      Result := False;
      break;
    end;
end;


function LinkOperatorToCode(link : TConditionLinkOperator) : WideString;
begin
  case link of
  loAND : Result := 'AND';
  loOR : Result := 'OR';
  else
    Result := 'Unknown TConditionLinkOperator (' + IntToStr(Ord(Link)) + ')';
  end;
end;

function CodeToLinkOperator(const code : WideString) : TConditionLinkOperator;
begin
  if (StringMatch(code, 'OR', [moIgnoreCase, moIgnoreSpaces])) then
    Result := loOR
  else
    Result := loAND;
end;


function _BuildSQL(SQLElement : ISQLElement; sql : TWideStringBuffer = nil; parameters : TParameterList = nil; const Indent : WideString = '') : WideString;
Var
  localParms, localBuff : Boolean;
begin
  localParms := false;
  localBuff := False;
  if (sql = nil) then begin
    sql := TWideStringBuffer.Create;
    localBuff := True;
  end;
  if (parameters = nil) then begin
    parameters := TParameterList.Create(nil);
    localParms := True;
  end;
  try
    SQLElement.buildSQL(sql, parameters, Indent);
    if (localParms) and (parameters.Count > 0) then
      raise ESQLFactoryException.Create('This SQL contains parameters, but no ' +
                                       'parameter list was given to collect them.');
    Result := sql.toString;
  finally
    if (localBuff) then
      safeFree(sql);
    if (localParms) then
      safeFree(parameters);
  end;
end;

function _VarAsString(V : Variant) : WideString;
begin
  try
    Result := VarToLiteralValue(V);
  except
    Result := 'Convert Error: ' + VarTypeAsText(VarType(v));
  end;
end;

function ConvertFloatToSQLLiteral(Value : Extended) : WideString;
Var
  fmt : TFormatSettings;
begin
  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, fmt);
  fmt.DecimalSeparator := '.';

  Result := FloatToStrF(Value, ffFixed, 17, 8, fmt);
end;

function VarRecToLiteralValue(const VarRec : TVarRec) : WideString;
Var
  d : Double;
begin
  case VarRec.VType of
    vtInteger:
      Result := ' ' + IntToStr(VarRec.VInteger) + ' ';

    vtBoolean:
      if VarRec.VBoolean then
        Result := ' 1 '
      else
        Result := ' 0 ';

    vtChar:
      Result := ' ''' + VarRec.VChar + ''' ';

    vtExtended: begin
      d := VarRec.VExtended^;
      Result := ConvertFloatToSQLLiteral(d);
    end;

    vtString:
      Result := ' ''' + VarRec.VString^ + ''' ';

    vtPChar:
      Result := ' ''' + VarRec.VPChar + ''' ';

    vtWideChar:
      if IsANSI(VarRec.VWideChar) then
        Result := ' ''' + VarRec.VWideChar + ''' '
      else
        Result := WideString(' N''') + VarRec.VWideChar + WideString(''' ');

    vtPWideChar:
      if IsANSIOnly(VarRec.VPWideChar) then
        Result := ' ''' + VarRec.VPWideChar + ''' '
      else
        Result := WideString(' N''') + VarRec.VPWideChar + WideString(''' ');

    vtAnsiString: begin
      Result := ' ''' + AnsiString(VarRec.VAnsiString) + ''' ';
    end;

    vtCurrency: begin
      Result := ConvertFloatToSQLLiteral(VarRec.VCurrency^);
    end;

    vtVariant: begin
      Result := VarToLiteralValue(VarRec.VVariant^);
    end;

    vtWideString: begin
      if IsANSIOnly(WideString(VarRec.VWideString)) then
        Result := ' ''' + WideString(VarRec.VWideString) + ''' '
      else
        Result := WideString(' N''') + WideString(VarRec.VWideString) + WideString(''' ');
    end;

    vtInt64:
      Result := ' ' + IntToStr(Int64(VarRec.VInt64^)) + ' ';

    else
      raise Exception.Create('Unknown value type');
  end; // case

end;

function VarToLiteralValue(Value : Variant) : WideString;
Var
  w: WideString;
begin
  if VarIsNull(Value) then
    Result := 'NULL'
  else case VarType(Value) of
    varSmallint,
    varInteger ,
    varSingle,
    varDouble,
    varCurrency,
    varShortInt,
    varByte,
    varWord,
    varLongWord,
    varInt64 :
      Result := ConvertFloatToSQLLiteral(Value);

    varDate:
      Result := WideString('''') + FormatDateTime('yyyy-mm-dd hh:nn:ss', Value) + WideString('''');

    varBoolean:
      if (Value) then
        Result := WideString('1')  // Bit Field
      else
        Result := WideString('0');

    varOleStr,
    varStrArg,
    varString: begin
      W := WideStringReplace(VarToWideStr(Value), '''', '''''', [rfReplaceAll]);
      if IsAnsiOnly(W) then
        W := '''' + W + ''''
      else
        W := WideString('N''') + W + WideString('''');
      Result := W;
    end
    else
      //  varUnknown :
      //  varVariant :
      //  varDispatch:
      //  varError :
      //  varEmpty:
      //  varNull:
      //  varAny :
  end;
end;


function _AsString(SQLElement : ISQLElement; AddParameters : Boolean = True): WideString;
Var
  parameters : TParameterList;
  sql : TWideStringBuffer;
begin
  parameters := TParameterList.Create(nil);
  sql := TWideStringBuffer.Create;
  try
    _buildSQL(SQLElement, sql, parameters, '');
    if AddParameters then begin
      sql.append(' -- parameters (');
      parameters.asString(sql);
      sql.append(')');
    end;
    Result := sql.toString;
  finally
    SafeFree(parameters);
    SafeFree(sql);
  end;
end;

{ TParameter }

procedure TParameter.SetValue(const Value : Variant);
begin
    fValue := Value;

end;

procedure TParameter.SetDataType(const Value : TDataType);
begin
  fDataType := Value;
end;

procedure TParameter.SetDirection(const Value : TParameterDirection);
begin
  fDirection := Value;
end;

procedure TParameter.SetSize(const Value : Integer);
begin
  fSize := Value;
end;

procedure TParameter.Assign(Source: TPersistent);
Var
  Other : TParameter;
begin
  if (Source <> nil) and (Source is TParameter) then begin
    Other := TParameter(Source);
    Self.Value := Other.Value;
    Self.DataType := Other.DataType;
    Self.Direction := Other.Direction;
    Self.Size := Other.Size;
  end
  else
    inherited;
end;

{ TParameterList }
constructor TParameterList.Create(AOwner : TPersistent = nil);
begin
  inherited Create(AOwner, TParameter);
end;

destructor TParameterList.Destroy;
begin

  inherited;
end;

function TParameterList.GetItem(Index: Integer): TParameter;
begin
  Result := TParameter(inherited GetItem(Index));
end;

function TParameterList.CreateParameter(Value : Variant; DataType : TDataType; Size : Integer; Direction : TParameterDirection) : TParameter;
begin
  Result := TParameter(Add);
  Result.Value := Value;
  Result.DataType := DataType;
  Result.Size := Size;
  Result.Direction := Direction;
end;

procedure TParameterList.addBooleanParameter(value: Boolean);
begin
  CreateParameter(Value, ftBoolean, 1, pdInput);
end;

procedure TParameterList.addIntegerParameter(value: Int64);
begin
  CreateParameter(Value, ftInteger, 4, pdInput);
end;

procedure TParameterList.addFloatParameter(value: Double);
begin
  CreateParameter(Value, ftFloat, 8, pdInput);
end;

procedure TParameterList.addStringParameter(const value: WideString);
begin
  CreateParameter(Value,ftWideString, Length(Value), pdInput);
end;

procedure TParameterList.addDateTimeParameter(value: TDateTime);
begin
  CreateParameter(VarAsDateTime(Value),ftDateTime, 8, pdInput);
end;

procedure TParameterList.addVariantParameter(value : OleVariant);
begin
  CreateParameter(Value, VarTypeToDataType(VarType(Value)), -1, pdInput);
end;

procedure TParameterList.addParameter(value : TParameter);
begin
  CreateParameter(Value.Value,Value.DataType, Value.Size, Value.Direction);
end;

procedure TParameterList.addParameters(source: TParameterList);
Var
  i : Integer;
begin
  for i := 0 to source.Count - 1 do
    CreateParameter(source[i].Value, source[i].DataType, source[i].Size, source[i].Direction);
end;

procedure TParameterList.copyTo(destination : TParameters);
Var
  i : Integer;
  ParmValue : Variant;
  ParmType : TFieldType;
begin
  for i := 0 to Count - 1 do begin
    if (Self[i].DataType = ftBoolean) then begin
      ParmType := ftInteger;
      if (VarIsType(Self[i].Value, varBoolean) and Self[i].Value) then
        ParmValue := -1
      else
        ParmValue := 0;
    end
    else begin
      ParmType := Self[i].DataType;
      ParmValue := Self[i].Value;
    end;

    if (i < destination.Count) then begin
      case destination[i].DataType of
      ftUnknown: begin
        destination[i].DataType := ParmType;
        destination[i].Value := ParmValue;
      end;

      ftSmallint, ftInteger, ftWord, ftLargeint:
        destination[i].Value := VarAsInteger(ParmValue);

      ftFloat, ftCurrency, ftBCD:
        destination[i].Value := VarAsDouble(ParmValue);

      ftBoolean:
        destination[i].Value := VarAsBoolean(ParmValue);

      ftDate, ftTime, ftDateTime, ftTimeStamp:
        destination[i].Value := VarAsDateTime(ParmValue);

      ftMemo, ftFmtMemo,ftFixedChar, ftWideString:
        destination[i].Value := VarAsWideString(ParmValue);

      else
        destination[i].Value := ParmValue;
      end;
      
      destination[i].Direction := Self[i].Direction;
    end
    else begin
      destination.CreateParameter('Parm' + IntToStr(i), ParmType,
                                  Self[i].Direction, Self[i].Size, ParmValue);
    end;
  end;
end;

procedure TParameterList.addVarRecParameter(value : TVarRec);
begin
  case Value.VType of
    vtInteger:    addIntegerParameter(Value.VInteger);
    vtBoolean:    addBooleanParameter(Value.VBoolean);
    vtChar:       addStringParameter(Value.VChar);
    vtExtended:   addFloatParameter(Value.VExtended^);
    vtString:     addStringParameter(Value.VString^);
    vtPChar:      addStringParameter(Value.VPChar);
    vtWideChar:   addStringParameter(Value.VWideChar);
    vtPWideChar:  addStringParameter(Value.VPWideChar);
    vtAnsiString: addStringParameter(AnsiString(Value.VAnsiString));
    vtCurrency:   addFloatParameter(Value.VCurrency^);
    vtVariant:    addVariantParameter(Value.VVariant^);
    vtWideString: addStringParameter(WideString(Value.VWideString));
    vtInt64:      addIntegerParameter(Int64(Value.VInt64^));
    else
      // Do nothing with these types
      //vtClass:      (VClass: TClass);
      //vtInterface:  (VInterface: Pointer);
      //vtObject:     (VObject: TObject);
      //vtPointer:    (VPointer : Pointer);
  end;
{$WARNINGS ON}
end;

procedure TParameterList.addParameters(source: array of const);
Var
  i : Integer;
begin
  for i := Low(source) to High(source) do
    AddVarRecParameter(source[i]);
end;

function TParameterList.asVariantArray: OleVariant;
Var
  i : Integer;
begin
  if (Count > 0) then begin
    Result := VarArrayCreate([0, Count-1], varVariant);
    for i := 0 to Count - 1 do
      Result[i] := Self.Parameter[i].Value;
  end
  else
      Result := EmptyParam;
end;

function TParameterList.AsString : WideString;
Var
  sql : TWideStringBuffer;
begin
  Result := '';
  if (Self = nil) then Exit;
  sql := TWideStringBuffer.Create;
  try
    self.AsString(sql);
    Result := sql.toString;
  finally
    SafeFree(sql);
  end;
end;


procedure TParameterList.AsString(sql : TWideStringBuffer);
Var
  i : Integer;
begin
  if (Self.Count > 0) then begin
    sql.append(_VarAsString(Self[0].Value));
    for i := 1 to Self.Count - 1 do begin
      sql.append(',');
      sql.append(_VarAsString(Self[i].Value));
    end;
  end;
end;

procedure TParameterList.Assign(Source: TPersistent);
Var
  Other : TParameterList;
  i : Integer;
begin
  if (Source <> nil) and (Source is TParameterList) then begin
    Self.Clear;
    Other := TParameterList(Source);
    for i := 0 to Other.Count - 1 do begin
      Self.addParameter(Other[i]);
    end;
  end
  else
    inherited;
end;

{ TSQLElement }
constructor TSQLElementItem.Create(AOwner : TCollection);
begin
  inherited Create(AOwner);
  if (AOwner <> nil) and (AOwner.Count > 1) then
    Index := AOwner.Count - 1;

  fObjectID := GetNextObjectID;
  f_ClassName := Self.ClassName;
end;

function TSQLElementItem._AddRef: Integer;
begin
  // We are not going to do reference counting
  Result := 1;
end;

function TSQLElementItem._Release: Integer;
begin
  // We are not going to do reference counting
  Result := 1;
end;

function TSQLElementItem.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TSQLElementItem.Match(const Key: WideString): Boolean;
begin
  Result := False;
end;

function TSQLElementItem.AsString: WideString;
begin
  Result := _asString(Self);
end;

function TSQLElementItem.GetDisplayName : String;
begin
  try
    Result := Self.ClassName + ': '+ _asString(Self, False);
  except
    Result := '';
  end;

  IF (Result = '') then
    Result := inherited GetDisplayName;
end;


function TSQLElementItem.buildSQL(parameters : TParameterList = nil) : WideString;
begin
  Result := _BuildSQL(Self, nil, parameters, '');
end;

procedure TSQLElementItem.Assign(Source : TPersistent);
begin
  if (Source = nil) or (not (Source is TSQLElementItem)) then
    inherited;
end;

{ TSQLElementList }
constructor TSQLElementList.Create(AOwner: TPersistent; ItemClass: TSQLElementItemClass);
begin
  inherited Create(AOwner, ItemClass);
  fObjectID := GetNextObjectID;
  f_ClassName := Self.ClassName;
end;

function TSQLElementList._GetItem(Key : Variant): TSQLElementItem;
Var
  idx : Integer;
begin
  idx := -1;
  if (VarIsNumeric(Key)) then try
    idx := Floor(Key);
  except
    idx := -1;
  end;

  if (idx < 0) then try
    idx := IndexOf(Key);
  except
    idx := -1;
  end;

  if (idx > -1) and (idx < Count) then
    Result := TSQLElementItem(inherited GetItem(Idx))
  else
    Result := nil;

end;

function TSQLElementList.InsertItem(Item: TSQLElementItem; Index: Integer = High(Integer)): TSQLElementItem;
begin
  if Item = nil then
    Result := TSQLElementItem(Add)
  else begin
    Result := Item;
    Result.Collection := Self;
  end;

  if Index >= Count then
    Index := Count -1
  else if (Index < 0) then
    Index := 0;

  Result.Index := Index;
end;

function TSQLElementList.IndexOf(const Key : WideString) : Integer;
begin
  for Result := 0 to Count - 1 do begin
    if (TSQLElementItem(GetItem(Result)).Match(Key)) then exit
  end;
  Result := -1;
end;

function TSQLElementList.AsString: WideString;
begin
  Result := _asString(Self);
end;

function TSQLElementList._AddRef: Integer;
begin
  // We are not going to do reference counting
  Result := 1;
end;

function TSQLElementList._Release: Integer;
begin
  // We are not going to do reference counting
  Result := 1;
end;

function TSQLElementList.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TSQLElementList.buildSQL(parameters : TParameterList = nil) : WideString;
begin
  Result := _BuildSQL(Self, nil, parameters, '');
end;

procedure TSQLElementList.Assign(Source : TPersistent);
Var
  Other : TSQLElementList;
  i : Integer;
begin
  if (Source <> nil) and (Source is TSQLElementList) then begin
    Other := TSQLElementList(Source);
    Self.Clear;
    for i := 0 to Other.Count - 1 do begin
      Self.Add.Assign(Other.Items[i]);
    end;
  end
  else
    inherited;
end;


{ TSQLElementParent }
constructor TSQLElementParent.Create(AOwner: TPersistent=nil);
begin
  inherited Create;
  fObjectID := GetNextObjectID;
  f_ClassName := Self.ClassName;
  fOwner := AOwner;
end;

function TSQLElementParent.GetOwner: TPersistent;
begin
  if (fOwner is TPersistent) then
    Result := TPersistent(FOwner)
  else
    Result := nil;
end;


function TSQLElementParent._AddRef: Integer;
begin
  Result := 1;
end;

function TSQLElementParent._Release: Integer;
begin
  Result := 1;
end;

function TSQLElementParent.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TSQLElementParent.AsString: WideString;
begin
  Result := _AsString(Self);
end;

function TSQLElementParent.buildSQL(
  parameters: TParameterList): WideString;
begin
  Result := _BuildSQL(Self, nil, Parameters, '');
end;

procedure TSQLElementParent.Assign(Source : TPersistent);
begin
  if (Source = nil) or (not (Source is TSQLElementParent)) then
    inherited;
end;


{ TParameteredElement }

destructor TParameteredElement.Destroy;
begin
  SafeFree(fParameters);
  inherited;
end;

function TParameteredElement.GetParameters: TParameterList;
begin
  if (not Assigned(fParameters)) then
    fParameters := TParameterList.Create(Self);
  Result := fParameters;
end;

procedure TParameteredElement.SetParameters(const Value : TParameterList);
begin
  if (Value <> fParameters) then begin
    if (fParameters <> nil) then
      SafeFree(fParameters);

    fParameters := Value;
  end;
end;


function TParameteredElement.CleanUp(const S : WideString) : WideString;
Var
  i : Integer;
  InQuotes : Boolean;
begin
  InQuotes := False;
  Result := s;
  for i := 1 to Length(Result) do begin
    // Question Marks, '?', establish parameters in MSSQL but Delphi
    //   doesn't recognize them.  It needs colons, ':'.
    if (not InQuotes) and (Result[i] = '?') then begin
      Result[i] := ':';
    end
    else if (Result[i] = '"') or (Result[i] = '''') then
      InQuotes := not InQuotes;
  end;
end;

procedure TParameteredElement.addFloatParameter(value: Extended);
begin
  Parameters.addFloatParameter(value);
end;

procedure TParameteredElement.addStringParameter(const value: WideString);
begin
  Parameters.addStringParameter(Value);
end;

procedure TParameteredElement.addBooleanParameter(value: Boolean);
begin
  Parameters.addBooleanParameter(Value);
end;

procedure TParameteredElement.addIntegerParameter(value: Int64);
begin
  Parameters.addIntegerParameter(Value);
end;

procedure TParameteredElement.addDateTimeParameter(value : TDateTime);
begin
  Parameters.addDateTimeParameter(Value);
end;


procedure TParameteredElement.addVariantParameter(Value : Variant);
begin
  Self.Parameters.addVariantParameter(Value);
end;

procedure TParameteredElement.addVarRecParameter(Value : TVarRec);
begin
  Self.Parameters.AddVarRecParameter(Value);
end;


procedure TParameteredElement.addParameters(parameters : TParameterList);
begin
  Self.Parameters.addParameters(parameters);
end;

procedure TParameteredElement.addParameters(parameters: array of const);
begin
  Self.Parameters.addParameters(parameters);
end;

procedure TParameteredElement.buildSQL(sql: TWideStringBuffer;  parameters: TParameterList; const indent : WideString = '');
begin
  InternalBuildParameters(parameters);
end;

procedure TParameteredElement.InternalBuildParameters(parameters: TParameterList);
begin
  if (parameters <> nil) then
    parameters.addParameters(Self.Parameters);
end;


{ TTable }

//constructor TTable.Create(AOwner : TPersistent);
//begin
//  if (AOwner is TOwnedCollection) then begin
//    inherited Create(TOwnedCollection(AOwner));
//    fOwnerRedirect := TOwnedCollection(AOwner);
//  end
//  else begin
//    fOwnerRedirect := TOwnedCollection.Create(AOwner, TTable);
//    inherited Create(fOwnerRedirect);
//  end;
//
//  fOwner := AOwner;
//end;
//
//function TTable.GetOwner : TPersistent;
//begin
//  Result := fOwner;
//end;
//
function TTable.Match(const Key : WideString) : Boolean;
begin
  if (TableAlias <> '') then
    Result := StringMatch(TableAlias, Key)
  else
    Result := StringMatch(TableName, Key);
end;

function TTable.GetTableAlias: WideString;
begin
  if (fTableAlias <> '') then
    Result := fTableAlias
  else
    Result := fTableName;
end;

function TTable.GetTableName: WideString;
begin
  Result := fTableName;
end;

function TTable.GetTableSchema: WideString;
begin
  Result := fTableSchema;
end;

procedure TTable.buildSQL(sql: TWideStringBuffer; parameters: TParameterList;
  const indent : WideString = '');
begin
  InternalBuildFullTableIdentifier(sql, indent);

  InternalBuildParameters(parameters);
end;

procedure TTable.InternalBuildFullTableIdentifier(sql: TWideStringBuffer; const indent : WideString);
var
  PeriodRequired: boolean;
begin
  PeriodRequired := false;
  if ServerName <> '' then begin
    InternalBuildTableServer( sql, indent );
    PeriodRequired := true;
  end;
  if PeriodRequired then sql.append('.');

  if DatabaseName <> '' then begin
    InternalBuildTableDatabase( sql, indent );
    PeriodRequired := true;
  end;
  if PeriodRequired then sql.append('.');

  if (tableSchema <> '') then begin
    InternalBuildTableSchema(sql, indent);
    PeriodRequired := true;
  end;
  if PeriodRequired then sql.append('.');

  InternalBuildTableName(sql, indent);

  if (tableAlias <> '') and (TableAlias <> TableName) then begin
    sql.append(' ');
    InternalBuildTableAlias(sql, indent);
  end;
end;

procedure TTable.InternalBuildTableServer(sql: TWideStringBuffer; const indent : WideString);
begin
  if AddDelimiters and (Copy(ServerName, 1, 1) <> '[') then
    sql.append('[');
  sql.append(ServerName);
  if AddDelimiters and (Copy(ServerName, 1, 1) <> '[') then
    sql.append(']');
end;

procedure TTable.InternalBuildTableDatabase(sql: TWideStringBuffer; const indent : WideString);
begin
  if AddDelimiters and (Copy(DatabaseName, 1, 1) <> '[') then
    sql.append('[');
  sql.append(DatabaseName);
  if AddDelimiters and (Copy(DatabaseName, 1, 1) <> '[') then
    sql.append(']');
end;

procedure TTable.InternalBuildTableSchema(sql: TWideStringBuffer; const indent : WideString);
begin
  if AddDelimiters and (Copy(TableSchema, 1, 1) <> '[') then
    sql.append('[');
  sql.append(tableSchema);
  if AddDelimiters and (Copy(TableSchema, 1, 1) <> '[') then
    sql.append(']');
end;

procedure TTable.InternalBuildTableName(sql: TWideStringBuffer; const indent : WideString);
begin
  if AddDelimiters then
      sql.append('[');
  sql.append(tableName);
  if AddDelimiters then
      sql.append(']');
end;

procedure TTable.InternalBuildTableAlias(sql: TWideStringBuffer; const indent : WideString);
begin
  if AddDelimiters and (Copy(TableAlias, 1, 1) <> '[') then
    sql.append('[');
  sql.append(tableAlias);
  if AddDelimiters and (Copy(TableAlias, 1, 1) <> '[') then
    sql.append(']');
end;

procedure TTable.SetTableAlias(const Value: WideString);
begin
  fTableAlias := Value;
end;

procedure TTable.SetTableSchema(const Value: WideString);
begin
  fTableSchema := Value;
end;

procedure TTable.SetTableName(const Value: WideString);
Var
  tmpSchema, tmpAlias : WideString;
begin
  ParseColumnInfo(Value, tmpSchema, fTableName, tmpAlias);
  if (tmpSchema <> '') then
    TableSchema := tmpSchema;
  if (tmpAlias <> '') then
    TableAlias := tmpAlias;
  if (TableAlias = '') then
    TableAlias := TableName;
  AddDelimiters := IsIdentifier(fTableName);
end;

procedure TParameteredElement.Assign(Source: TPersistent);
begin
  inherited;
  if (Source <> nil) and (Source is TParameteredElement) then
    Self.Parameters.Assign(TParameteredElement(Source).Parameters);
end;

procedure TTable.Assign(Source: TPersistent);
Var
  Other : TTable;
begin
  inherited;
  if (Source <> nil) and (Source is TTable) then begin
    Other := TTable(Source);
    Self.TableSchema := Other.TableSchema;
    Self.TableName := Other.TableName;
    Self.TableAlias := Other.TableAlias;
    Self.AddDelimiters := Other.AddDelimiters;
  end;
end;

{ TColumn }
function TColumn.GetTableName: WideString;
begin
  Result := fTableName;
end;

function TColumn.GetColumnName: WideString;
begin
  Result := fColumnName;
end;

procedure TColumn.SetTableName(Const Value : WideString);
begin
  fTableName := Value;
end;

procedure TColumn.SetColumnName(const Value : WideString);
Var
  tmpTableName, tmpColumnAlias : WideString;
begin
  ParseColumnInfo(Value, tmpTableName, fColumnName, tmpColumnAlias);
  if (tmpTableName <> '') then
    TableName := tmpTableName;

  fAddDelimiters := IsIdentifier(fColumnName);
end;

function TColumn.Match(const Str : WideString) : Boolean;
begin
  Result := StringMatch(ColumnName, Str);
end;

procedure TColumn.buildSQL(sql: TWideStringBuffer; parameters: TParameterList; const indent : WideString = '');
begin
  if (tableName <> '') then begin
    if AddDelimiters then
      sql.append('[');
    sql.append(tablenAME);
    if AddDelimiters then
      sql.append(']');
    sql.append('.');
  end;

  if AddDelimiters then
      sql.append('[');
  sql.append(columnName);
  if AddDelimiters then
      sql.append(']');

end;

procedure TColumn.Assign(Source: TPersistent);
Var
  Other : TColumn;
begin
  inherited;
  if (Source <> nil) and (Source is TColumn) then begin
    Other := TColumn(Source);
    Self.TableName := Other.TableName;
    Self.ColumnName := Other.ColumnName;
    Self.AddDelimiters := Other.AddDelimiters;
  end;
end;

{ TCustomColumnList }
constructor TCustomColumnList.Create(AOwner: TPersistent; ItemClass: TSQLElementItemClass);
begin
  inherited;

  fColumnsPerRow := 3;
end;

function TCustomColumnList.GetField(Key : Variant) : TColumn;
begin
  Result := TColumn(_GetItem(Key));
end;

procedure TCustomColumnList.buildSQL(sql: TWideStringBuffer; parameters: TParameterList;
  const indent : WideString = '');
Var
  i, p : Integer;
  fieldsWithoutBreak : Integer;
begin
  if (Self.Count = 0) then Exit;
  fieldsWithoutBreak := 0;
  Self.Field[0].buildSQL(sql, parameters, indent);
  for i := 1 to Self.Count - 1 do begin
    sql.append(', ');
    if (fieldsWithoutBreak >= ColumnsPerRow) then begin
      sql.append(#13#10);
      sql.append(indent);
      sql.append(STD_INDENT);
      fieldsWithoutBreak := 0;
    end;
    p := sql.length;
    Self.Field[i].buildSQL(sql, parameters, indent);
    inc(fieldsWithoutBreak);
    // Did we add a CR to the string?
    if (sql.find(#13, p + 1) > 0) then
      fieldsWithoutBreak := 0
  end;
end;

{ TColumnList }

constructor TColumnList.Create(AOwner : TPersistent = nil);
begin
  inherited Create(AOwner, TColumn);
end;

procedure TColumnList.Add(Field: TColumn);
begin
  InsertItem(Field);
end;

{ TFieldValueDef }
function TFieldValueDef.getLiteralValue: Variant;
begin
  Result := fLiteralValue;
end;

procedure TFieldValueDef.SetLiteralValue(Value: Variant);
begin
  fLiteralValue := Value;
  fIsLiteral := True;
  fUseRaw := False;
  Parameters.Clear;
end;

procedure TFieldValueDef.ClearLiteral;
begin
  fIsLiteral := False;
  fLiteralValue := Unassigned;
end;

function TFieldValueDef.GetIsLiteral: WordBool;
begin
  Result := fIsLiteral;
end;

function TFieldValueDef.GetUseRaw : WordBool;
begin
  Result := fUseRaw;
end;

procedure TFieldValueDef.SetUseRaw(Value : WordBool);
begin
  if Value and (IsLiteral) and VarIsStr(fLiteralValue) then
    fUseRaw := True
  else
    fUseRaw := False;
end;

function TFieldValueDef.GetIsParameter: WordBool;
begin
  Result := Self.Parameters.Count > 0;
end;

function TFieldValueDef.GetMaxLength : Integer;
begin
  Result := fMaxLength;
end;

procedure TFieldValueDef.SetMaxLength(Value : Integer);
begin
  fMaxLength := Value;
end;

procedure TFieldValueDef.BuildValue(sql: TWideStringBuffer;  parameters: TParameterList);
Var
  ws : WideString;
begin
  if (IsParameter) then begin
    if  (Self.Parameters[0].DataType in [ftDateTime, ftDate, ftTime])
     and (VarAsDateTime(Self.Parameters[0].Value) = 0)
    then
      sql.append('NULL')
    else begin
      parameters.addParameter(Self.Parameters[0]);
      if   (MaxLength > 0)
       and (Self.Parameters[0].DataType in [ftString, ftMemo, ftFixedChar, ftWideString])
       and (Self.Parameters[0].Direction in [pdInput, pdInputOutput])
      then begin
        ws := Copy(VarAsWideString(Self.Parameters[0].Value), 1, MaxLength);
        parameters.Parameter[parameters.Count-1].Value := ws;
      end;
      sql.append(':');
    end;
  end
  else if (isLiteral) then begin
    if UseRaw then
      sql.append(VarAsWideString(literalValue))
    else if VarIsNull(LiteralValue) or StringMatch(VarToLiteralValue(LiteralValue), 'NULL') then
      sql.append('NULL')
    else if (MaxLength > 0) and VarIsType(literalValue, [varString, varOleStr, varStrArg]) then begin
      ws := VarAsWideString(literalValue);
      sql.append(VarToLiteralValue(Copy(ws, 1, maxLength)));
    end
    else
      sql.append(VarToLiteralValue(literalValue));
  end
  else
    raise ESQLFactoryException.Create('No insert value defined for ' + ColumnName);
end;

procedure TFieldValueDef.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  // We don't want to call inherited cause we don't want a tableAlias and
  //  we don't want to add the parameters at this time.
  // NO: inherited buildSQL(sql, new ArrayList(), indent);
  sql.append('[');
  sql.append(ColumnName);
  sql.append(']');

end;

procedure TFieldValueDef.Assign(Source: TPersistent);
Var
  Other : TFieldValueDef;
begin
  inherited;
  if (Source <> nil) and (Source is TFieldValueDef) then begin
    Other := TFieldValueDef(Source);
    if (Other.IsLiteral) then begin
      Self.LiteralValue := Other.LiteralValue;
      if (Other.UseRaw) then
        Self.UseRaw := True;
    end
    else
      Self.ClearLiteral;
  end;
end;

//function TORCondition.GetDisplayName: WideString;
//Var
//  i : Integer;
//begin
//  if (Conditions.Count > 0) then begin
//    Result := '(' + Conditions[0].DisplayName;
//    for i := 1 to Conditions.Count - 1 do begin
//      Result := Result + ') OR (' + Conditions[i].DisplayName;
//    end;
//    Result := Result + ')';
//  end
//  else
//    Result := inherited GetDisplayName;
//end;

{ TFieldValueList }
constructor TFieldValueList.Create(AOwner : TPersistent = nil);
begin
  inherited Create(AOwner, GetSQLElementItemClass);
end;

function TFieldValueList.GetSQLElementItemClass : TSQLElementItemClass;
begin
  Result := TFieldValueDef;
end;

function TFieldValueList.Add(Column: TFieldValueDef): TFieldValueDef;
begin
  Result := TFieldValueDef(InsertItem(Column));
end;

function TFieldValueList.Insert(columnPos: Integer; Column: TFieldValueDef): TFieldValueDef;
begin
  Result := TFieldValueDef(InsertItem(Column, columnPos));
end;

function TFieldValueList.GetColumn(Key: Variant): TFieldValueDef;
begin
  Result := TFieldValueDef(_GetItem(Key));
end;

function TFieldValueList.Add(const columnName: WideString): TFieldValueDef;
begin
  Result := insert(Count, columnName);
end;

function TFieldValueList.Add(const columnName : WideString; literalValue : Boolean) : TFieldValueDef;
begin
  Result := Add(columnName );
  Result.LiteralValue := literalValue;
end;

function TFieldValueList.Add(const columnName : WideString; literalValue : Int64) : TFieldValueDef;
begin
  Result := add(columnName );
  Result.LiteralValue := literalValue;
end;

function TFieldValueList.Add(const columnName : WideString; literalValue : Extended) : TFieldValueDef;
begin
  Result := add(columnName );
  Result.LiteralValue := literalValue;
end;

function TFieldValueList.Add(const columnName : WideString; const literalValue : WideString; maxLength : Integer=-1) : TFieldValueDef;
begin
  Result := Add(columnName );
  if MaxLength > 0 then
    Result.maxLength := maxLength;
  Result.LiteralValue := literalValue;
end;

function TFieldValueList.addDateTime(const columnName : WideString; literalValue : TDateTime) : TFieldValueDef;
begin
  Result := Add(columnName );
  Result.LiteralValue := literalValue;
end;

function TFieldValueList.addVariant(const columnName: WideString; literalValue : OleVariant): TFieldValueDef;
begin
  Result := Add(columnName );
  Result.LiteralValue := literalValue;
end;

procedure TFieldValueList.Add(columnNames: array of Widestring);
begin
  Insert(Count, columnNames);
end;

procedure TFieldValueList.Add(columnNames : array of Widestring; literalValues : array of const);
begin
  Insert(Count, columnNames, literalValues);
end;

function TFieldValueList.Insert(columnPos: Integer; const columnName: WideString): TFieldValueDef;
begin
  Result := TFieldValueDef(Insert(columnPos));
  Result.ColumnName := columnName;
end;

function TFieldValueList.Insert(columnPos: Integer; const columnName: WideString; literalValue : Boolean): TFieldValueDef;
begin
  Result := Insert(columnPos, columnName);
  Result.literalValue := literalValue;
end;

function TFieldValueList.Insert(columnPos: Integer; const columnName: WideString; literalValue : Int64): TFieldValueDef;
begin
  Result := Insert(columnPos, columnName);
  Result.literalValue := literalValue;
end;

function TFieldValueList.Insert(columnPos: Integer; const columnName: WideString; literalValue : Extended): TFieldValueDef;
begin
  Result := Insert(columnPos, columnName);
  Result.literalValue := literalValue;
end;

function TFieldValueList.Insert(columnPos: Integer; const columnName: WideString; const literalValue : WideString): TFieldValueDef;
begin
  Result := Insert(columnPos, columnName);
  Result.literalValue := literalValue;
end;

function TFieldValueList.InsertDateTime(columnPos: Integer; const columnName: WideString; literalValue : TDateTime): TFieldValueDef;
begin
  Result := Insert(columnPos, columnName);
  Result.literalValue := literalValue;
end;

function TFieldValueList.insertVariant(columnPos: Integer; const columnName: WideString; literalValue : OleVariant): TFieldValueDef;
begin
  Result := Insert(columnPos, columnName);
  Result.literalValue := literalValue;
end;

procedure TFieldValueList.Insert(columnPos: Integer;
  columnNames: array of WideString);
Var
  i : Integer;
begin
  for i := High(columnNames) downto 0 do begin
    Insert(columnPos, columnNames[i]);
  end;
end;

procedure TFieldValueList.Insert(columnPos : Integer; columnNames : array of WideString; literalValues : array of const);
Var
  i : Integer;
begin
  for i := High(columnNames) downto Low(columnNames) do begin
    if (i <= High(literalValues)) and (i >= Low(literalValues)) then
      case literalValues[i].VType of
        vtInteger:    Insert(columnPos, columnNames[i], literalValues[i].VInteger);
        vtBoolean:    Insert(columnPos, columnNames[i], literalValues[i].VBoolean);
        vtChar:       Insert(columnPos, columnNames[i], literalValues[i].VChar);
        vtExtended:   Insert(columnPos, columnNames[i], literalValues[i].VExtended^);
        vtString:     Insert(columnPos, columnNames[i], literalValues[i].VString^);
        vtPChar:      Insert(columnPos, columnNames[i], literalValues[i].VPChar);
        vtWideChar:   Insert(columnPos, columnNames[i], literalValues[i].VWideChar);
        vtPWideChar:  Insert(columnPos, columnNames[i], literalValues[i].VPWideChar);
        vtAnsiString: Insert(columnPos, columnNames[i], AnsiString(literalValues[i].VAnsiString));
        vtCurrency:   Insert(columnPos, columnNames[i], literalValues[i].VCurrency^);
        vtVariant:    InsertVariant(columnPos, columnNames[i], literalValues[i].VVariant^);
        vtWideString: Insert(columnPos, columnNames[i], WideString(literalValues[i].VWideString));
        vtInt64:      Insert(columnPos, columnNames[i], Int64(literalValues[i].VInt64^));
        else
          // Do nothing with these types
          //vtClass:      (VClass: TClass);
          //vtInterface:  (VInterface: Pointer);
          //vtObject:     (VObject: TObject);
          //vtPointer:    (VPointer : Pointer);
      end
    else
      Insert(columnPos, columnNames[i]);

  end;
end;

function TFieldValueList.BuildValuesList(sql: TWideStringBuffer;
  parameters: TParameterList; const Indent: WideString) : Boolean;
Var
  i : Integer;
begin
    Result := false;
    if (Count > 0) then begin
      if ( Column[0].isParameter or Column[0].isLiteral) then begin
         Result := true;
         sql.append('VALUES (');
         Column[0].buildValue(sql, parameters);
         for i := 1 to Count - 1 do begin
           sql.append(', ');
           if ((i mod 4) = 0) then
            sql.append(#13);
           Column[i].buildValue(sql, parameters);
         end;
         sql.append(')');
      end
    end;
end;

procedure TFieldValueList.RemoveColumn(const columnName : WideString);
Var
  Idx : Integer;
begin
  Idx := IndexOf(ColumnName);
  if (Idx > 0) then
    Self.Delete(Idx);
end;

{ TCondition }
constructor TCondition.Create(AOwner : TCollection);
begin
  inherited Create(AOwner);
  if (AOwner is TConditionList) then
    Self.LinkOperator := TConditionList(AOwner).DefaultLink
  else
    fLinkOperator := loAND;
end;

procedure TCondition.Assign(Other : TPersistent);
begin
  if (Other is TCondition) then begin
    Self.LinkOperator := TCondition(Other).LinkOperator;
    Self.IsNegative := TCondition(Other).IsNegative;
  end;
  inherited Assign(Other);
end;

{ TSimpleCondition }
constructor TSimpleCondition.Create(AOwner: TCollection);
begin
  inherited Create(AOwner);
  fExpression := '';
  fLinkOperator := loAND;
  fLiteralValue := Unassigned;
end;

constructor TSimpleCondition.Create(AOwner: TCollection;
  const Expression: WideString; LinkOperator: TConditionLinkOperator);
begin
  Create(AOwner);
  Self.Expression := Expression;
  Self.LinkOperator := LinkOperator;
end;

procedure TSimpleCondition.Assign(Other : TPersistent);
begin
  if (Other is TSimpleCondition) then begin
    Self.Expression := TSimpleCondition(Other).Expression;
    Self.LiteralValue := TSimpleCondition(Other).LiteralValue;
  end;

  inherited Assign(Other);
end;

function TSimpleCondition.GetExpression: WideString;
begin
  Result := fExpression;
end;

function TSimpleCondition.Match(const Key : WideString) : Boolean;
Var
  p : Integer;
  S1, S2 : WideString;
begin
  s1 := StripChars(['[', ']', '(', ')'], Key);
  s2 := StripChars(['[', ']', '(', ')'], Expression);

  Result := StringMatch(s1, s2, [moIgnoreCase, moIgnoreSpaces]);

  if (not Result) then begin
    p := Pos('=', s2);
    if (p = -1) then
      p := Pos('<', s2);
    if (p = -1) then
      p := Pos('>', s2);
    if (p = -1) then
      p := Pos(' IS ', s2);
    if (p = -1) then
      p := Pos(' IN ', s2);
    if (P > -1) then
      Result := StringMatch(s1, Copy(s2, 1, p - 1), [moIgnoreCase, moIgnoreSpaces]);
  end;
end;

procedure TSimpleCondition.SetExpression(const Value: WideString);
begin
  fExpression := CleanUp(Value);
end;

function TSimpleCondition.GetHasLiteralValue : WordBool;
begin
  Result := not VarIsEmpty(fLiteralValue);
end;

function TSimpleCondition.GetLiteralValueAsText : WideString;
begin
  if (HasLiteralValue) then begin
    if UseRaw and VarIsStr(fLiteralValue) then
      Result := fLiteralValue
    else if VarIsNull(FLiteralValue) then
      Result := 'NULL'
    else
      Result := VarToLiteralValue(fLiteralValue);
  end
  else
    Result := '';
end;

function TSimpleCondition.GetUseRaw : Boolean;
begin
  Result := fUseRaw;
end;

procedure TSimpleCondition.SetUseRaw(Value : Boolean);
begin
  fUseRaw := Value;
end;

procedure TSimpleCondition.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent : WideString = '');
Var
  AddParens : Boolean;
begin
  if (IsNegative) then
    sql.append('( NOT ');
  AddParens := Copy(Trim(Expression), 1, 1) <> '(';
  if (AddParens) then
    sql.append('(');
  if HasLiteralValue then
    sql.append(WideStringReplace(Expression, ':', LiteralValueAsText, []))
  else
    sql.append(Expression);
  if (AddParens) then
    sql.append(') ')
  else
    sql.append(' ');
  if (IsNegative) then
    sql.append(')');
  inherited buildSQL(sql, parameters, indent);
end;

{ TConditionGroup }
constructor TConditionGroup.Create(AOwner : TCollection);
begin
  inherited;
  fConditions := TConditionList.Create(Self);
end;

constructor TConditionGroup.Create(AOwner : TCollection; DefaultLink : TConditionLinkOperator);
begin
  Create(AOwner);
  Conditions.DefaultLink := DefaultLink;
end;

constructor TConditionGroup.Create(AOwner : TCollection;
  conditions : array of WideString; DefaultLink : TConditionLinkOperator = loOR);
begin
  Create(AOwner, DefaultLink);
  Self.Conditions.Add(Conditions, DefaultLink);
end;

destructor TConditionGroup.Destroy;
begin
  SafeFree(fConditions);

  inherited;
end;

procedure TConditionGroup.Assign(Other : TPersistent);
begin
  if (Other is TConditionGroup) then begin
    Self.Conditions.Assign(TConditionGroup(Other).Conditions);
  end;

  inherited Assign(Other);
end;

procedure TConditionGroup.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent : WideString = '');
//Var
//  i : Integer;
begin
  if (conditions.Count > 0) then begin
    if (IsNegative) then
      sql.append('( NOT ');
    sql.append('(');
    Conditions.BuildSQL(sql, parameters, indent);
  //    conditions[0].buildSQL(sql, parameters, indent);
  //    for i := 1 to conditions.Count - 1 do begin
  //      sql.append(' ');
  //      sql.append(LinkOperatorToCode(conditions[i].LinkOperator));
  //      sql.append(' ');
  //      conditions[i].buildSQL(sql, parameters, indent);
  //    end;
    sql.append(')');
    if (IsNegative) then
      sql.append(')');
    if (Self.Parameters.Count > 0) then
      parameters.addParameters(Self.Parameters);
  end;
end;

function TConditionGroup.GetConditions: TConditionList;
begin
  if (fConditions = nil) then
    fConditions := TConditionList.Create(Self);
  Result := fConditions;
end;

function TConditionGroup.GetDisplayName: String;
Var
  i : integer;
  WResult : WideString;
begin
  try
    if (Conditions.Count > 0) then begin
      WResult := Conditions[0].GetDisplayName;
      for i := 1 to Conditions.Count - 1 do begin
        WResult := WResult + ' OR ' + Conditions[i].GetDisplayName;
      end;
    end
  except
    WResult := '';
  end;
  if (WResult = '') then
    Result := inherited GetDisplayName
  else
    Result := WideStringToString(WResult);
end;
{ TINListCondition }

constructor TINListCondition.Create(AOwner: TCollection);
begin
  inherited Create(AOwner);
  fValues := TStringList.Create;
  fAddQuotes := True;
end;

constructor TINListCondition.Create(AOwner: TCollection;
  const ValueExpression: WideString; RawValues: array of WideString);
begin
  Create(AOwner);
  fValueExpression := ValueExpression;
  if Length(RawValues) > 0 then 
    SetRawValues(RawValues);
end;

destructor TINListCondition.Destroy;
begin
  SafeFree(fValues);
  inherited;
end;

procedure TINListCondition.Assign(Other : TPersistent);
begin
  if (Other is TINListCondition) then begin
    Self.ValueExpression := TINListCondition(Other).ValueExpression;
    Self.Values := TINListCondition(Other).Values;
  end;

  inherited Assign(Other);
end;

function TINListCondition.GetValues: TStringList;
begin
  Result := fValues;
end;

procedure TINListCondition.SetFloatValues(FloatValues: array of Double; Precision : Integer = 17; Decimals : Integer = 4);
Var
  i : Integer;
begin
  for i := Low(FloatValues) to High(FloatValues) do
    Self.Values.Add(FloatToStrF(FloatValues[i], ffFixed, Precision, Decimals));
  AddQuotes := False;
end;

procedure TINListCondition.SetIntegerValues(IntegerValues: array of Integer);
Var
  i : Integer;
begin
  for i := Low(IntegerValues) to High(IntegerValues) do
    Self.Values.Add(IntToStr(IntegerValues[i]));
  AddQuotes := False;
end;

procedure TINListCondition.SetStringValues(StringValues: array of WideString);
Var
  i : Integer;
begin
  for i := Low(StringValues) to High(StringValues) do
    Self.fValues.Add(StringValues[i]);
  AddQuotes := True;
end;

//procedure TINListCondition.SetStringValues(StringValues : TWideStringList);
//Var
//  i : Integer;
//begin
//  for i := 0 to StringValues.Count - 1 do
//    Self.Values.Add('''' + StringValues[i] + '''');
//end;

procedure TINListCondition.SetStringValues(StringValues : TStrings);
Var
  i : Integer;
begin
  for i := 0 to StringValues.Count - 1 do
    Self.fValues.Add(StringValues[i]);
  AddQuotes := True;
end;

procedure TINListCondition.SetRawValues(RawValues: array of WideString);
Var
  i : Integer;
begin
  for i := Low(RawValues) to High(RawValues) do
    Self.fValues.Add(RawValues[i]);
  AddQuotes := False;
end;

procedure TINListCondition.SetValues(const Value: TStringList);
begin
  if (Self.Values <> Value) then begin
    if (Value = nil) then
      Self.fValues.Clear
    else begin
      SafeFree(Self.fValues);
      Self.fValues := Value;
    end;
  end;
end;

function TINListCondition.GetDisplayName: String;
begin
  Result := WideStringToString(ValueExpression + ' IN [{list}]');
end;

procedure TINListCondition.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
Var
  i : Integer;
begin
  if (Values.Count > 0) then begin
    if (IsNegative) then
      sql.append('( NOT');
    sql.append('( ');
    sql.append(ValueExpression);
    sql.append(' IN (');
    if AddQuotes and (Copy(Values[0], 1,1) <> '''') then
      sql.append('''' + StringReplace(values[0], '''', '''''', [rfReplaceAll]) + '''')
    else
      sql.append(values[0]);
    for i := 1 to Values.Count - 1 do begin
      sql.append(',');
      if AddQuotes and (Copy(Values[i], 1,1) <> '''') then
        sql.append('''' + StringReplace(Values[i], '''', '''''', [rfReplaceAll]) + '''')
      else
        sql.append(Values[i]);
    end;
    sql.append(') )');
    if (IsNegative) then
      sql.append(')');
  end;
end;

{ TConditionList }
constructor TConditionList.Create(AOwner : TPersistent);
begin
  inherited Create(AOwner, TCondition);
  fDefaultLink := loAND;
end;

constructor TConditionList.Create(AOwner : TPersistent; DefaultLink : TConditionLinkOperator);
begin
  Create(AOwner);
  Self.DefaultLink := DefaultLink;
end;

procedure TConditionList.Assign(Other: TPersistent);
Var
  i : Integer;
  OtherList : TConditionList;
  ConditionClass : TConditionClass;
  Clone : TCondition;
begin
  if (not (Other is TConditionList)) then
    inherited Assign(Other)
  else begin
    OtherList := TConditionList(Other);
    Self.DefaultLink := OtherList.DefaultLink;
    for i := 0 to OtherList.Count - 1 do begin
      ConditionClass := TConditionClass(OtherList[i].ClassType);
      Clone := ConditionClass.Create(Self);
      Clone.Assign(OtherList[i]);
    end;
  end;

end;

function TConditionList.GetCondition(Idx: Integer): TCondition;
begin
  Result := TCondition(GetItem(Idx));
end;

function TConditionList.Add(Condition : TCondition) : TCondition;
begin
  Result := TCondition(InsertItem(Condition));
end;

function TConditionList.Add(const expression: WideString): TSimpleCondition;
begin
  Result := Add(expression, DefaultLink);
end;

function TConditionList.Add(const expression: WideString; LinkOperator : TConditionLinkOperator): TSimpleCondition;
begin
  Result := TSimpleCondition.Create(Self, Expression, LinkOperator);
  Add(Result);
end;

procedure TConditionList.Add(conditions: array of WideString);
begin
  Add(conditions, DefaultLink);
end;

procedure TConditionList.Add(conditions: array of WideString;
  LinkOperator: TConditionLinkOperator);
var
  i : Integer;
begin
  for i := Low(conditions) to High(Conditions) do begin
    Add(conditions[i], LinkOperator);
  end;
end;

function TConditionList.AddGroup(LinkOperator : TConditionLinkOperator) : TConditionGroup;
begin
  Result := AddGroup([], LinkOperator);
end;

function TConditionList.AddGroup(conditions: array of WideString; LinkOperator : TConditionLinkOperator = loOR) : TConditionGroup;
begin
  Result := TConditionGroup.Create(Self, conditions, LinkOperator);
end;

function TConditionList.AddInList(ValueExpression : WideString; RawValues : array of WideString ) : TInListCondition;
begin
  Result := TInListCondition.Create(Self, ValueExpression, RawValues);
end;

function TConditionList.AddInList(ValueExpression : WideString; RawValues : TStringList) : TInListCondition;
begin
  Result := TInListCondition.Create(Self, ValueExpression, []);
  Result.Values.AddStrings(RawValues);
end;

procedure TConditionList.AddParameterized(Fields : array of WideString; Values : Variant);
begin
  AddParameterized(AsVariantArray(Fields), Values);
end;

procedure TConditionList.AddParameterized(Fields : Variant; Values : Variant) ;
Var
  VarIdx : Integer;

  procedure _AddWhere(Idx : Integer);
  Var
    f : WideString;
    v : Variant;
    p : Integer;
    Cond : TSimpleCondition;
    AddBrackets : Boolean;
    IdentOnly : Boolean;
  begin
    f := VarArrayVal(Fields, idx, '');
    Cond := Add(f);
    AddBrackets := True;
    IdentOnly := True;
    for p := 1 to length(f) do begin
      if IdentOnly
        and (not InCharSet(f[p],['0'..'9', 'a'..'z', 'A'..'Z', ' ','.', '[', ']', '_']))
      then
        IdentOnly := False;

      if AddBrackets and InCharSet(f[p],['[', ']', '.']) then
        AddBrackets := False;
        
      if ((f[p] = ':') or (f[p] = '?'))then begin
        v := VarArrayVal(Values, VarIdx, NULL);
        inc(VarIdx);
        Cond.AddVariantParameter(v)
      end;
    end;

    // If all characters are either spaces or Alpha Numeric
    //  And there is a parameter value to be filled in
    // then we just assume this should be an equality comparison
    if (IdentOnly) then begin
      v := VarArrayVal(Values, VarIdx, NULL);
      inc(VarIdx);
      if (not VarIsNull(v)) then begin
        if (AddBrackets) then
          Cond.Expression := '[' + f + '] = :'
        else
          Cond.Expression := f + ' = :';
        Cond.AddVariantParameter(v)
      end;
    end
  end;
Var
  i : Integer;
begin
  VarIdx := 0;

  if VarIsArray(Fields) then begin
    for i := VarArrayLowBound(Fields, 1) to VarArrayHighBound(Fields, 1) do begin
      _AddWhere(i);
    end
  end
  else
    _AddWhere(0);
end;




procedure TConditionList.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent : WideString = '');
Var
  i : Integer;
begin
  if (Self.Count > 0) then begin
    Self.Condition[0].buildSQL(sql, parameters, indent);

    for i := 1 to Self.Count - 1 do begin
      sql.append(#13#10);
      sql.append(indent);
      sql.append(WidePadL(LinkOperatorToCode(Self.Condition[i].LinkOperator), 5));
      sql.append(' ');
      Self.Condition[i].buildSQL(sql, parameters, indent);
    end;
  end;
end;

function TTable.GetDatabaseName: WideString;
begin
  Result := fDatabaseName;
end;

function TTable.GetServerName: WideString;
begin
  Result := fServerName;
end;

procedure TTable.SetDatabaseName(const Value: WideString);
begin
  fDatabaseName := Value;
end;

procedure TTable.SetServerName(const Value: WideString);
begin
  fServerName := Value;
end;

initialization
{$IFNDEF NOUNITVERSION}
  RegisterUnit('$Source: /Procurement2/shared/SQLFactoryBase.pas,v $', '$Revision: 1.46 $', '$Date: 2014/08/15 22:25:44 $');
{$ENDIF}
  _ObjectID := 0;
  if (_ObjectID > 0) then
    // I just don't want this eliminated by the debugger.
    TParameterList(nil).AsString;

end.

