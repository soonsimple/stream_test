program main
   !
   !Fortran流文件 - 读取二进制文件
   !
   ! 流文件的基本用法

   ! 流文件（access="stream"）是 Fortran2003 新增的一种读写方式，目前主流的尚在更新的编译器均支持。

   ! 它是一种读写方式，而不是文件本身的格式。
   ! 它并不把二进制文件视为一个一个的“记录”，而是视为一个整体。
   ! 因此，无需指定记录长度（RecL）。

   ! 文件打开后，操作位置就在文件的第一个字节上，每次读取多少字节，就自动向后移动多少字节。下一次读写紧接着此处。
   ! 同时，流文件也提供任意位置（字节数），以及查询当前位置的方法。

   ! 1. 打开流文件
   ! 一个典型的流文件读写二进制，可使用以下语句：
   ! Open( 12 , File = "fcode_test.bin" , access="stream" , form = "unformatted" )
   ! access 指定打开方式为流文件，form 指定文件为无格式文件（二进制文件）

   ! 2.读写
   ! 读写时也无需指定记录（rec），典型的读取语句：
   ! Read( 12 ) 变量1 , 变量2 , 变量3...... 变量 N
   ! 此时，在当前操作位置读写。读写后，操作位置自动向后移动 M 个字节（M等于所有读写的变量占有的字节数）
   ! 注意：无格式读写，不能指定格式，也不能写 *

   ! 如果想在其他位置读写，可使用这样的语句：
   ! Read( 12 , pos = i ) 变量1 , 变量2 , 变量3...... 变量 N
   ! 此时，在第 i 个字节处开始读取。读写后，操作位置相对 i 向后移动 M 个字节（M 同上）

   ! 3.查询当前操作位置
   ! 经过若干 read 语句或 write 语句后，可能就不知道当前读取位置在哪儿了。此时，可通过 Inquire 查询：
   ! Inquire( 12 , Pos = i )
   ! 以上语句执行后，i 的值会变为 12 号文件当前的操作位置（字节数）

   ! 4.设置当前操作位置
   ! 我们经常要跳过若干字节，或回退若干字节进行读写。这可以通过查询操作位置后，加减一定数量，再设置为当前操作位置。例如：
   ! Inquire( 12 , Pos = i )
   ! Read( 12 , Pos= i + 32 , iostat = iErr )
   ! 用 Read 语句来设置当前位置为 i + 32（即向后跳过 32 字节），而 Read 后面没有任何变量。
   ! iostat = iErr 可以防止超过文件大小而出错。

   ! 5.关闭流文件
   ! 使用 Close(12)  关闭，与常规文件没有区别。
   !
   ! 详见：http://fcode.cn/guide-86-1.html
   !
   use, intrinsic :: iso_c_binding
   implicit none
   type, bind(c) :: grad_head
      character(kind=c_char) :: flag(1:4)
      integer(kind=c_short) :: m, n
      real(kind=c_double) :: rxmin, rxmax
      real(kind=c_double) :: rymin, rymax
      real(kind=c_double) :: rzmin, rzmax
   end type grad_head

   type(grad_head) :: Head
   real, allocatable :: d(:, :)
   integer :: i

   open (12, file='fcode_test.grd', access='stream', form='unformatted')
   read (12) Head
   allocate (d(Head%m, Head%n))

   write (*, *) 'flag = ', Head%flag
   write (*, *) 'm/n = ', Head%m, Head%n
   write (*, *) 'X-Min = ', Head%rxmin, 'X_Max = ', Head%rxmax
   write (*, *) 'Y-Min = ', Head%rymin, 'Y_Max = ', Head%rymax
   write (*, *) 'Z-Min = ', Head%rzmin, 'Z_Max = ', Head%rzmax

   inquire (12, pos=i)

   write (*, '(a,1x,i4,1x,a)') 'Head have', i - 1, 'Bytes totally.'
   read (12) d(:, :)

   do i = 1, Head%n
      write (*, '(*(f6.3))') d(:, i)
   end do

   close (12)
   print *, ''

end program main
