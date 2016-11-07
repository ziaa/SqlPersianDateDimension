/***************************************************
  Author:		Seyed Zia Azimi
 
  Description:	Create dbo.PersianDateDimension table (if does't exist) and populate it with Gregorian and Persian dates
                between specified @FromDate & @ToDate
  
  Example:      EXECUTE dbo.spPopulatePersianDateDimension @FromDate = '2016-1-1', @ToDate = '2017-1-1'

  TODO:         Uncomment "PersianDayNumberOfYear" after debugging "GregorianToJalali" function
****************************************************/ 

CREATE PROCEDURE [dbo].[spPopulatePersianDateDimension]
    @FromDate DATETIME ,
    @ToDate DATETIME
AS
    BEGIN
        SET NOCOUNT ON;

        BEGIN TRAN

        IF OBJECT_ID('dbo.PersianDateDimension', 'U') IS NULL
            BEGIN
                CREATE TABLE dbo.PersianDateDimension
                    (
                      [DateKey] [INT] PRIMARY KEY CLUSTERED
                                      NOT NULL ,
                      [FullDateAlternateKey] [DATE] NOT NULL ,
                      [GregorianDayNumberOfWeek] [TINYINT] NOT NULL ,
                      [GregorianDayNameOfWeek] [NVARCHAR](10) NOT NULL ,
                      [GregorianDayNumberOfMonth] [TINYINT] NOT NULL ,
                      [GregorianDayNumberOfYear] [SMALLINT] NOT NULL ,
                      [GregorianWeekNumberOfYear] [TINYINT] NOT NULL ,
                      [GregorianMonthName] [NVARCHAR](10) NOT NULL ,
                      [GregorianMonthNumberOfYear] [TINYINT] NOT NULL ,
                      [GregorianYear] [SMALLINT] NOT NULL ,
                      [PersianDateKey] [INT] NOT NULL ,
                      [PersianDate] [NCHAR](10) NOT NULL ,
                      [PersianDayNumberOfWeek] [TINYINT] NOT NULL ,
                      [PersianDayNameOfWeek] [NVARCHAR](8) NOT NULL ,
                      [PersianDayNumberOfMonth] [TINYINT] NOT NULL ,
                      --[PersianDayNumberOfYear] [SMALLINT] NOT NULL ,
                      [PersianMonthName] [NVARCHAR](8) NOT NULL ,
                      [PersianMonthNumberOfYear] [TINYINT] NOT NULL ,
                      [PersianYear] [SMALLINT] NOT NULL ,
                    )
            END

        DECLARE @dates TABLE ( FullDate DATE )

        WHILE @FromDate <= @ToDate
            BEGIN 
                INSERT  INTO @dates
                        ( FullDate )
                        SELECT  @FromDate

                SET @FromDate = DATEADD(dd, 1, @FromDate)
            END 

        INSERT  INTO dbo.PersianDateDimension
                ( DateKey ,
                  FullDateAlternateKey ,
                  GregorianDayNumberOfWeek ,
                  GregorianDayNameOfWeek ,
                  GregorianDayNumberOfMonth ,
                  GregorianDayNumberOfYear ,
                  GregorianWeekNumberOfYear ,
                  GregorianMonthName ,
                  GregorianMonthNumberOfYear ,
                  GregorianYear ,
                  PersianDateKey ,
                  PersianDate ,
                  PersianDayNumberOfWeek ,
                  PersianDayNameOfWeek ,
                  PersianDayNumberOfMonth ,
                  --PersianDayNumberOfYear ,
                  PersianMonthName ,
                  PersianMonthNumberOfYear ,
                  PersianYear
                )
                SELECT  CONVERT(INT, CONVERT(VARCHAR, d.FullDate, 112)) AS DateKey ,
                        d.FullDate ,
                        DATEPART(dw, d.FullDate) AS GregorianDayNumberOfWeek ,
                        DATENAME(WEEKDAY, d.FullDate) AS GregorianDayNameOfWeek ,
                        DATEPART(d, d.FullDate) AS GregorianDayNumberOfMonth ,
                        DATEPART(dy, d.FullDate) AS GregorianDayNumberOfYear ,
                        DATEPART(wk, d.FUllDate) AS GregorianWeekNumberOfYear ,
                        DATENAME(MONTH, d.FullDate) AS GregorianMonthName ,
                        MONTH(d.FullDate) AS GregorianMonthNumberOfYear ,
                        YEAR(d.FullDate) AS GregorianYear ,
                        CONVERT(INT, dbo.GregorianToJalali(d.FullDate,
                                                           'SaalMaah2Rooz2')) AS PersianDateKey ,
                        dbo.GregorianToJalali(d.FullDate, 'Saal/Maah2/Rooz2') AS PersianDate ,
                        CONVERT(TINYINT, dbo.GregorianToJalali(d.FullDate,
                                                              'ChandShanbeAdadi')) AS PersianDayNumberOfWeek ,
                        dbo.GregorianToJalali(d.FullDate, 'ChandShanbe') AS PersianDayNameOfWeek ,
                        CONVERT(TINYINT, dbo.GregorianToJalali(d.FullDate,
                                                              'Rooz')) AS PersianDayNumberOfMonth ,
                        --CONVERT(SMALLINT, dbo.GregorianToJalali(d.FullDate,
                        --                                      'SaalRooz')) AS PersianDayNumberOfYear ,
                        dbo.GregorianToJalali(d.FullDate, 'MaahHarfi') AS PersianMonthName ,
                        CONVERT(SMALLINT, dbo.GregorianToJalali(d.FullDate,
                                                              'Maah')) AS PersianMonthNumberOfYear ,
                        CONVERT(SMALLINT, dbo.GregorianToJalali(d.FullDate,
                                                              'Saal')) AS PersianYear
                FROM    @dates d
                        LEFT JOIN dbo.PersianDateDimension pd ON d.FullDate = pd.FullDateAlternateKey
                WHERE   pd.FullDateAlternateKey IS NULL 

        COMMIT TRAN
    END

GO