/***************************************************
   Main script written by Seyed Mahdi Movashah which is taken from http://rastan.parsiblog.com/Posts/381
   Optimized By Mir Asghar Mehdizadeh (Mamehdi) which is taken from http://mamehdi.parsiblog.com/Posts/1

   Example: PRINT dbo.GregorianToJalali('2016-11-7', 'Saal/Maah2/Rooz2')
			PRINT dbo.GregorianToJalali(GETDATE(), 'Rooz MaahHarfi Saal')
****************************************************/ 

CREATE FUNCTION [dbo].[GregorianToJalali]
    (
      @GregorianDate DATETIME ,
      @OutputFormat AS NVARCHAR(MAX)
    )
RETURNS NVARCHAR(MAX)
    BEGIN

		/* OutputFormat Rules: (پنجشنبه 7 اردیبهشت 1394)
		ChandShanbe -> پنجشنبه (روز هفته به حروف)
		ChandShanbeAdadi -> 6 (روز هفته به عدد)
		Rooz -> 7 (چندمین روز از ماه)
		Rooz2 -> 07 (چندمین روز از ماه دو کاراکتری)
		Maah -> 2 (چندمین ماه از سال)
		Maah2 -> 02 (چندمین ماه از سال دو کاراکتری)
		MaahHarfi -> اردیبهشت (نام ماه به حروف)
		Saal -> 1394 (سال چهار کاراکتری)
		Saal2 -> 94 (سال دو کاراکتری)
		Saal4 -> 1394 (سال چهار کاراکتری)
		SaalRooz -> 38 (چندمین روز سال)
		Default OutputFormat -> 'ChandShanbe Rooz MaahHarfi Saal'
		*/

        DECLARE @YY SMALLINT= YEAR(@GregorianDate) ,
            @MM TINYINT= 10 ,
            @DD SMALLINT= 11 ,
            @DDCNT TINYINT ,
            @YYDD SMALLINT= 0 ,
            @SHMM NVARCHAR(8) ,
            @SHDD NVARCHAR(8)
        DECLARE @SHDATE NVARCHAR(MAX)



        IF @YY < 1000
            SET @YY += 2000

        IF ( @OutputFormat IS NULL )
            OR NOT LEN(@OutputFormat) > 0
            SET @OutputFormat = 'ChandShanbe Rooz MaahHarfi Saal'

        SET @YY -= 622

        IF @YY % 4 = 3
            AND @YY > 1371
            SET @DD = 12

        SET @DD += DATEPART(DY, @GregorianDate) - 1

        WHILE 1 = 1
            BEGIN

                SET @DDCNT = CASE WHEN @MM < 7 THEN 31
                                  WHEN @YY % 4 < 3
                                       AND @MM = 12
                                       AND @YY > 1370 THEN 29
                                  WHEN @YY % 4 <> 2
                                       AND @MM = 12
                                       AND @YY < 1375 THEN 29
                                  ELSE 30
                             END
                IF @DD > @DDCNT
                    BEGIN
                        SET @DD -= @DDCNT
                        SET @MM += 1
                        SET @YYDD += @DDCNT
                    END
                IF @MM > 12
                    BEGIN
                        SET @MM = 1
                        SET @YY += 1
                        SET @YYDD = 0
                    END
                IF @MM < 7
                    AND @DD < 32
                    BREAK
                IF @MM BETWEEN 7 AND 11
                    AND @DD < 31
                    BREAK
                IF @MM = 12
                    AND @YY % 4 < 3
                    AND @YY > 1370
                    AND @DD < 30
                    BREAK
                IF @MM = 12
                    AND @YY % 4 <> 2
                    AND @YY < 1375
                    AND @DD < 30
                    BREAK
                IF @MM = 12
                    AND @YY % 4 = 2
                    AND @YY < 1371
                    AND @DD < 31
                    BREAK
                IF @MM = 12
                    AND @YY % 4 = 3
                    AND @YY > 1371
                    AND @DD < 31
                    BREAK

            END

        SET @YYDD += @DD

        SET @SHMM = CASE WHEN @MM = 1 THEN N'فروردین'
                         WHEN @MM = 2 THEN N'اردیبهشت'
                         WHEN @MM = 3 THEN N'خرداد'
                         WHEN @MM = 4 THEN N'تیر'
                         WHEN @MM = 5 THEN N'مرداد'
                         WHEN @MM = 6 THEN N'شهریور'
                         WHEN @MM = 7 THEN N'مهر'
                         WHEN @MM = 8 THEN N'آبان'
                         WHEN @MM = 9 THEN N'آذر'
                         WHEN @MM = 10 THEN N'دی'
                         WHEN @MM = 11 THEN N'بهمن'
                         WHEN @MM = 12 THEN N'اسفند'
                    END
   

        SET @SHDD = CASE WHEN DATEPART(dw, @GregorianDate) = 7 THEN N'شنبه'
                         WHEN DATEPART(dw, @GregorianDate) = 1 THEN N'یکشنبه'
                         WHEN DATEPART(dw, @GregorianDate) = 2 THEN N'دوشنبه'
                         WHEN DATEPART(dw, @GregorianDate) = 3 THEN N'سه‌شنبه'
                         WHEN DATEPART(dw, @GregorianDate) = 4 THEN N'چهارشنبه'
                         WHEN DATEPART(dw, @GregorianDate) = 5 THEN N'پنجشنبه'
                         WHEN DATEPART(dw, @GregorianDate) = 6 THEN N'جمعه'
                    END
        SET @DDCNT = CASE WHEN @SHDD = N'شنبه' THEN 1
                          WHEN @SHDD = N'یکشنبه' THEN 2
                          WHEN @SHDD = N'دوشنبه' THEN 3
                          WHEN @SHDD = N'سه‌شنبه' THEN 4
                          WHEN @SHDD = N'چهارشنبه' THEN 5
                          WHEN @SHDD = N'پنجشنبه' THEN 6
                          WHEN @SHDD = N'جمعه' THEN 7
                     END


        SET @SHDATE = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@OutputFormat,
                                                                                             'MaahHarfi', @SHMM),
                                                                                         'SaalRooz', LTRIM(STR(@YYDD,3))),
                                                                                     'ChandShanbeAdadi',@DDCNT),
                                                                                 'ChandShanbe', @SHDD),
															                 'Rooz2', REPLACE(STR(@DD,2), ' ', '0')),
                                                                     'Maah2', REPLACE(STR(@MM,2), ' ', '0')),
                                                              'Saal2', SUBSTRING(STR(@YY,4), 3, 2)),
                                                     'Saal4', STR(@YY, 4)),
                                             'Saal', LTRIM(STR(@YY, 4))),
                                      'Maah', LTRIM(STR(@MM, 2))), 
							 'Rooz', LTRIM(STR(@DD, 2)))

		/* OutputFormat Samples:
		OutputFormat='ChandShanbe Rooz MaahHarfi Saal' -> پنجشنبه 17 اردیبهشت 1394
		OutputFormat='Rooz MaahHarfi Saal' -> ـ 17 اردیبهشت 1394
		OutputFormat='Rooz/Maah/Saal' -> 1394/2/17
		OutputFormat='Rooz2/Maah2/Saal2' -> 94/02/17
		OutputFormat='Rooz روز گذشته از MaahHarfi در سال Saal2' -> ـ 17 روز گذشته از اردیبهشت در سال 94
		*/

        RETURN @SHDATE
    END

GO