USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateCenterID]    Script Date: 3/11/2015 4:56:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 03/11/2015
-- Description:	
-- 
-- =============================================
ALTER PROCEDURE  [dbo].[uspUpdateMultiLeaderFK] 
AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
	        @DT1dSRID        INT, 
	        @CenterID        INT, 
			@SRName          NVARCHAR(1000);

	ALTER TABLE MultiLeader
	DROP CONSTRAINT FKMultiLeaderDT1dSR;

	SET @myCur = CURSOR FOR
	select d.dt1dsrID,  l.CenterID, l.SRName
		from dt1dsr d,
			  multiLeader l
		where d.fy = 2013
		--and   d.grantnumber = 43703
		and   d.centerID = l.centerID
		and   d.SRName = l.SRName;
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @DT1dSRID,  @CenterID, @SRName
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	    UPDATE multiLeader
		SET    DT1DSRID = @DT1dSRID
		WHERE  CenterID = @CenterID
		AND    SRName   = @SRName
		AND    FY       = 2013;
		    
		FETCH NEXT
		FROM @myCur INTO @DT1dSRID,  @CenterID, @SRName
		
	END 
	CLOSE @myCur
	DEALLOCATE @myCur

	ALTER TABLE [dbo].[MultiLeader]  WITH NOCHECK ADD  CONSTRAINT [FKMultiLeaderDT1dSR] FOREIGN KEY([DT1dSRID])
	REFERENCES [dbo].[DT1dSR] ([DT1dSRID])

END
