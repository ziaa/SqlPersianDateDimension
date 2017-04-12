<div dir="rtl">
## راهنمای ساختن بُعد تاریخ شمسی برای استفاده در OLAP Cube

### 1. [ایجاد کردن تابع تبدیل میلادی به شمسی](GregorianToJalali.sql)
### 2. [ساختن جدول نگهدارنده تاریخ‌ها و روالِ (Stored Procedure) پُر کردن این جدول](spPopulatePersianDateDimension.sql)
### 3. پُر کردن بُعد تاریخ برای یک بازه زمانی خاص
</div>

```
EXECUTE dbo.spPopulatePersianDateDimension @FromDate = '2016-1-1', @ToDate = '2017-1-1'
```

<div dir="rtl">
همین!

[یه ذره (!) اطلاعات بیشتر](http://daftar.ziaa.ir/posts/2017/01/Create_and_populate_Persian_date_dimension_to_be_used_in_OLAP_Cubes/)
</div>
