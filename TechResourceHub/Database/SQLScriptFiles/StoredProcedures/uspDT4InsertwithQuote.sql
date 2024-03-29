USE  OCC 
GO
/****** Object:  StoredProcedure  dbo . uspInsertDT4WithQuote     Script Date: 6/13/2014 5:37:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- ================================================================================
-- DATE 		DESC
   06/13/2014   replace single quote with double quotes
 
-- ================================================================================  */
ALTER PROCEDURE   uspInsertDT4withQuote  (@pGrantNumber VARCHAR(15)) 

AS
BEGIN
	
	DECLARE @myCur					CURSOR,
		    @FY				INT,
	   @CenterID			INT,
       @grantnumber			INT,
	   @ClinicalResearchCat VARCHAR(255),
	   @StudySource			VARCHAR(100),
	   @PrimaryPurpose		VARCHAR(100),
       @FundingSource		VARCHAR(255),
       @PrimarySite			VARCHAR(255),
       @ProtocolID			VARCHAR(255),
       @PILastName			VARCHAR(255),
       @PIFirstName			VARCHAR(255),
	   @PIMiddleName		VARCHAR(255),
       @ProgCode			VARCHAR(255),
       @OpenDate			DATETIME,
       @CloseDate			DATETIME,
       @Phase				VARCHAR(255),
       @Title				VARCHAR(8000),
       @EntireStudy			INT,
	   @YourCenterTotal		INT,
       @CenterP12			INT,
       @Center2Date			INT,
       @OthP12				INT,
       @Oth2Date			INT,
	   @ReportingStartDate  DATETIME,
	   @ReportingEndDate	DATETIME,
	   @isMultiInst			CHAR(1)
	        

	   
	SET @myCur = CURSOR FOR
	SELECT 
	   2013 as FY
	   ,c.CenterID
       ,c.grantnumber 
	   ,ClinicalResearchCat 
	   ,StudySource 
	   ,PrimaryPurpose
       ,FundingSource 
       ,PrimarySite 
       ,ProtocolID
       ,PILastName
       ,PIFirstName
	   ,Null as PIMiddleName
       ,ProgCode 
       ,OpenDate 
       ,CloseDate 
       ,Phase 
       ,Title
       ,EntireStudy
	   ,YourCenterTotal
       ,enterP12 
       ,Center2Date 
       ,OthP12  
       ,Oth2Date 
	   ,Null as ReportingStartDate
	   ,NULL AS ReportingEndDate
	   ,NULL AS isMultiInst
  FROM  [DT4-77598-FY13Negative]  d,
        Center c 
  WHERE d.GrantNumber = c.GrantNumber
  AND   d.GrantNumber = 77598; 

	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @FY, 					@CenterID,			@grantnumber, 
					 @ClinicalResearchCat,	@StudySource,		@PrimaryPurpose,
					 @FundingSource,		@PrimarySite,		@ProtocolID,
					 @PILastName,			@PIFirstName,		@PIMiddleName,
		 			 @ProgCode,				@OpenDate,			@CloseDate,
					 @Phase,				@Title,				@EntireStudy,
					 @YourCenterTotal,      @CenterP12,			@Center2Date,
					 @OthP12,				@Oth2Date,
					 @ReportingStartDate,	@ReportingEndDate,	@isMultiInst

	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	   
	   INSERT INTO  DT4 
			( FY,  CenterID ,  Grantnumber   
			 ,ClinicalResearchCat, StudySourceCode, PrimaryPurpose
			 ,FundingSource,  PrimarySite  , ProtocolID  
			 ,PILastName   , PIFirstName  ,piMiddleName
			 ,ProgCode   , OpenDate   , CloseDate  
			 ,Phase  ,Title  ,  EntireStudy 
			 ,YourCenterTotal , CenterP12 , Center2Date  
			 ,OthP12			,Oth2Date,  
			 ReportingStartDate, ReportingEndDate, isMultiInst)  
			 
	VALUES( 
	   @FY, 	              @CenterID,         @grantnumber, 
	   @ClinicalResearchCat,  @StudySource,      @PrimaryPurpose,
       @FundingSource,        @PrimarySite,      @ProtocolID,
       @PILastName,           @PIFirstName,	     @PIMiddleName,
       @ProgCode,             @OpenDate,         @CloseDate,
       @Phase,                @Title,            @EntireStudy,
	   @YourCenterTotal,      @CenterP12,        @Center2Date,
       @OthP12,               @Oth2Date,
	   @ReportingStartDate,	  @ReportingEndDate, @isMultiInst)
 
		    


		FETCH NEXT@FY, 	 @CenterID,  @grantnumber, 
	@ClinicalResearchCat, @StudySource,  @PrimaryPurpose,
       @FundingSource,  @PrimarySite,  @ProtocolID,
       @PILastName,       @PIFirstName,	   @PIMiddleName,
       @ProgCode,       @OpenDate,       @CloseDate,
       @Phase,       @Title,       @EntireStudy,
	   @YourCenterTotal,       @CenterP12,       @Center2Date,
       @OthP12,       @Oth2Date,
	   @ReportingStartDate,	   @ReportingEndDate,	   @isMultiInst@P30TypeID, @GrantNumber
		
	END 
	CLOSE @myCur
	DEALLOCATE @myCur
	         
	
  

END
