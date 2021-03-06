# 从源码角度彻底搞懂String,StringBuffer,StringBuilder

*本篇文章已授权微信公众号 guolin_blog （郭霖）独家发布

> 从源码角度彻底分析三者底层实现.第一次写源码分析,小记一笔,由于本人才疏学浅,有很多地方可能存在误解和不足,还望大家在评论区批评指正.

## 一.引言

  学Java很久了,一直处于使用API+查API的状态,不了解原理,久而久之总是觉得很虚,作为一名合格的程序员这是不允许的,不能一直当API Player,我们要去了解分析底层实现,下次在使用时才能知己知彼.知道在什么时候该用什么方法和什么类比较合适.

![](https://upload-images.jianshu.io/upload_images/3994917-f60bdfe3afcba051.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

  在之前,我知道的关于String,StringBuffer,StringBuilder的知识点大概如下

  1. String是不可变的（修改String时，不会在原有的内存地址修改，而是重新指向一个新对象），String用final修饰，不可继承，String本质上是个final的char[]数组，所以char[]数组的内存地址不会被修改，而且String 也没有对外暴露修改char[]数组的方法.不可变性可以保证线程安全以及字符串串常量池的实现.频繁的增删操作是不建议使用String的.
  2. StringBuffer是线程安全的,多线程建议使用这个.
  3. StringBuilder是非线程安全的,单线程使用这个更快.

对于上面这些结论,我也不知道从哪里来的,,,,感觉好像是前辈的经验吧,,,好了,废话不多说,直接上代码吧.

![](https://upload-images.jianshu.io/upload_images/3994917-cd3c64eb6fa97663.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 二.String源码分析

看下继承结构源码:

```java
public final class String
    implements java.io.Serializable, Comparable<String>, CharSequence {
    /** The value is used for character storage. */
    private final char value[];
    ...
}
```

可以看到String是final的,不允许继承.里面用来存储value的是一个final数组,也是不允许修改的.String有很多方法,下面就String类常用方法进行分析.

### 1.构造方法

```java
public String() {
    this.value = "".value;
}
public String(String original) {
    this.value = original.value;
    this.hash = original.hash;
}
public String(char value[]) {
    this.value = Arrays.copyOf(value, value.length);
}
...
```
可以看到默认的构造器是构建的空字符串,其实所有的构造器就是给value数组赋初值.

### 2.字符串长度
返回该字符串的长度,这太简单了,就是返回value数组的长度.
```java
public int length() {
    return value.length;
}
```
### 3.字符串某一位置字符
返回字符串中指定位置的字符；
```java
public char charAt(int index) {
    //1. 首先判断是否越界
    if ((index < 0) || (index >= value.length)) {
        throw new StringIndexOutOfBoundsException(index);
    }
    //2. 返回相应位置的值
    return value[index];
}
```
### 4.提取子串

用String类的substring方法可以提取字符串中的子串，简单分析一下substring(int beginIndex, int endIndex)吧,该方法从beginIndex位置起，从当前字符串中取出到endIndex-1位置的字符作为一个 **新的字符串(重新new了一个String)** 返回.

方法内部是将数组进行部分复制完成的,所以该方法不会对原有的数组进行更改.

```java
public String substring(int beginIndex, int endIndex) {
    //1.验证入参是否越界
    if (beginIndex < 0) {
        throw new StringIndexOutOfBoundsException(beginIndex);
    }
    if (endIndex > value.length) {
        throw new StringIndexOutOfBoundsException(endIndex);
    }
    //2. 记录切割长度
    int subLen = endIndex - beginIndex;
    //3. 入参合法性
    if (subLen < 0) {
        throw new StringIndexOutOfBoundsException(subLen);
    }
    //4. 如果开始切割处是0,结束切割处是value数组长度,那么相当于没有切割嘛,就直接返回原字符串;如果是其他情况:则重新新建一个String对象
    return ((beginIndex == 0) && (endIndex == value.length)) ? this
            : new String(value, beginIndex, subLen);
}

/**
* 通过一个char数组复制部分内容生成一个新数组,复制区间:从offset到offset+count处.
*/
public String(char value[], int offset, int count) {
    if (offset < 0) {
        throw new StringIndexOutOfBoundsException(offset);
    }
    if (count <= 0) {
        if (count < 0) {
            throw new StringIndexOutOfBoundsException(count);
        }
        //count==0
        if (offset <= value.length) {
            this.value = "".value;
            return;
        }
    }
    // Note: offset or count might be near -1>>>1.
    if (offset > value.length - count) {
        throw new StringIndexOutOfBoundsException(offset + count);
    }
    //复制一部分
    this.value = Arrays.copyOfRange(value, offset, offset+count);
}

```

### 5.字符串比较

- **compareTo(String anotherString)**

  该方法是对字符串内容按字典顺序进行大小比较，通过返回的整数值指明当前字符串与参数字符串的大小关系.若当前对象比参数大则返回正整数，反之返回负整数，相等返回0.

  主要是挨个字符进行比较

```java
public int compareTo(String anotherString) {
    //1. 记录长度
    int len1 = value.length;
    int len2 = anotherString.value.length;
    //2. 最短长度
    int lim = Math.min(len1, len2);
    char v1[] = value;
    char v2[] = anotherString.value;

    int k = 0;
    //3. 循环逐个字符进行比较,如果不相等则返回字符之差  
    //这里只需要循环lim次就行了
    while (k < lim) {
        char c1 = v1[k];
        char c2 = v2[k];
        if (c1 != c2) {
            //可能是正数或负数
            return c1 - c2; 
        }
        k++;
    }
    //4. 最后返回长度之差    这里可能是0,即相等
    return len1 - len2;
}
```

- **compareToIgnore(String anotherString)**

  与compareTo()方法相似，但忽略大小写.

  实现:从下面的源码可以看出,最终实现是通过一个内部类CaseInsensitiveComparator,它实现了Comparator和Serializable接口,并实现了compare()方法,里面的实现方法和上面的compareTo()方法差不多,只不过忽略大小写.

```java
public int compareToIgnoreCase(String str) {
    return CASE_INSENSITIVE_ORDER.compare(this, str);
}
public static final Comparator<String> CASE_INSENSITIVE_ORDER
                                        = new CaseInsensitiveComparator();
private static class CaseInsensitiveComparator
        implements Comparator<String>, java.io.Serializable {
    // use serialVersionUID from JDK 1.2.2 for interoperability
    private static final long serialVersionUID = 8575799808933029326L;

    public int compare(String s1, String s2) {
        int n1 = s1.length();
        int n2 = s2.length();
        int min = Math.min(n1, n2);
        for (int i = 0; i < min; i++) {
            char c1 = s1.charAt(i);
            char c2 = s2.charAt(i);
            if (c1 != c2) {
                c1 = Character.toUpperCase(c1);
                c2 = Character.toUpperCase(c2);
                if (c1 != c2) {
                    c1 = Character.toLowerCase(c1);
                    c2 = Character.toLowerCase(c2);
                    if (c1 != c2) {
                        // No overflow because of numeric promotion
                        return c1 - c2;
                    }
                }
            }
        }
        return n1 - n2;
    }

    /** Replaces the de-serialized object. */
    private Object readResolve() { return CASE_INSENSITIVE_ORDER; }
}
```

- **equals(Object anotherObject)**

  比较当前字符串和参数字符串，在两个字符串相等的时候返回true，否则返回false.

  大体实现思路:
  1. 先判断引用是否相同
  2. 再判断该Object对象是否是String的实例
  3. 再判断两个字符串的长度是否一致
  4. 最后挨个字符进行比较

```java
public boolean equals(Object anObject) {
    //1. 引用相同  
    if (this == anObject) {
        return true;
    }

    //2. 是String的实例?
    if (anObject instanceof String) {
        String anotherString = (String)anObject;
        int n = value.length;
        //3. 长度
        if (n == anotherString.value.length) {
            char v1[] = value;
            char v2[] = anotherString.value;
            int i = 0;
            //4. 挨个字符进行比较
            while (n-- != 0) {
                if (v1[i] != v2[i])
                    return false;
                i++;
            }
            return true;
        }
    }
    return false;
}
```

- **equalsIgnoreCase(String anotherString)**

  与equals方法相似，但忽略大小写.但是这里要稍微复杂一点,因为牵连到另一个方法regionMatches(),没关系,下面跟着我一起慢慢分析.

  在equalsIgnoreCase()方法里面首先是校验引用值是否一致,再判断否为空,紧接着判断长度是否一致,最后通过regionMatches()方法测试两个字符串每个字符是否相等(忽略大小写).

  在regionMatches()方法中其实还是比较简单的,就是逐字符进行比较,当需要进行忽略大小写时,如果遇到不相等的2字符,先统一转成大写进行比较,如果相同则继续比较下一个,不相同则转成小写再判断是否一致.

```java
public boolean equalsIgnoreCase(String anotherString) {
    return (this == anotherString) ? true
            : (anotherString != null)
            && (anotherString.value.length == value.length)
            && regionMatches(true, 0, anotherString, 0, value.length);
}
public boolean regionMatches(boolean ignoreCase, int toffset,
            String other, int ooffset, int len) {
        char ta[] = value;
        int to = toffset;
        char pa[] = other.value;
        int po = ooffset;
        // Note: toffset, ooffset, or len might be near -1>>>1.
        if ((ooffset < 0) || (toffset < 0)
                || (toffset > (long)value.length - len)
                || (ooffset > (long)other.value.length - len)) {
            return false;
        }
        while (len-- > 0) {
            //循环校验每个字符是否相等,相等则继续校验下一个字符
            char c1 = ta[to++];
            char c2 = pa[po++];
            if (c1 == c2) {
                continue;
            }

            //如果遇到不相等的2字符,再判断是否忽略大小写.
            //先统一转成大写进行比较,如果相同则继续比较下一个,不相同则转成小写再判断是否一致
            if (ignoreCase) {
                // If characters don't match but case may be ignored,
                // try converting both characters to uppercase.
                // If the results match, then the comparison scan should
                // continue.
                char u1 = Character.toUpperCase(c1);
                char u2 = Character.toUpperCase(c2);
                if (u1 == u2) {
                    continue;
                }
                // Unfortunately, conversion to uppercase does not work properly
                // for the Georgian alphabet, which has strange rules about case
                // conversion.  So we need to make one last check before
                // exiting.
                if (Character.toLowerCase(u1) == Character.toLowerCase(u2)) {
                    continue;
                }
            }
            return false;
        }
        return true;
    }
```
### 6.字符串连接

将指定字符串联到此字符串的结尾，效果等价于"+".

实现思路:构建一个新数组,先将原来的数组复制进新数组里面,再将需要连接的字符串复制进新数组里面(存放到后面).

```java
public String concat(String str) {
    //1. 首先获取传入字符串长度  咦,居然没有对入参合法性进行判断?万一是null呢
    int otherLen = str.length();
    //2. 如果传入字符串长度为0,就没必要往后面走了
    if (otherLen == 0) {
        return this;
    }
    //3. 记录当前数组长度
    int len = value.length;
    //4. 搞一个新数组(空间大小为len + otherLen),前面len个空间用来存放value数组
    char buf[] = Arrays.copyOf(value, len + otherLen);
    //5. 将str存入buf数组的后面otherLen个空间里面
    str.getChars(buf, len);
    //6. new一个String将新建的buf数组传入
    return new String(buf, true);
}

//将des数组复制进value数组中,dstBegin:目的数组放置的起始位置
void getChars(char dst[], int dstBegin) {
    System.arraycopy(value, 0, dst, dstBegin, value.length);
}

//这里的share参数貌似总是为true   所以是暂时没用咯??
String(char[] value, boolean share) {
    // assert share : "unshared not supported";
    this.value = value;
}

```

### 7.字符串中单个字符查找

- **indexOf(int ch/String str)** 

  返回指定字符在此字符串中第一次出现处的索引,在该对象表示的字符序列中第一次出现该字符的索引，如果未出现该字符，则返回 -1。

  其实该方法最后是调用的`indexOf(ch/str, 0);` 该方法放到下面进行分析.

- **indexOf(int ch/String str, int fromIndex)**

  该方法与第一种类似，区别在于该方法从fromIndex位置向后查找.

  先分析indexOf(int ch, int fromIndex),该方法是查找ch在fromIndex索引之后第一次出现的索引.主要就是逐个字符进行比较,相同则返回索引.如果未找到则返回-1.

```java
public int indexOf(int ch, int fromIndex) {
    final int max = value.length;
    //1. 边界
    if (fromIndex < 0) {
        fromIndex = 0;
    } else if (fromIndex >= max) {
        // Note: fromIndex might be near -1>>>1.
        return -1;
    }

    //2. 是否是罕见字符
    if (ch < Character.MIN_SUPPLEMENTARY_CODE_POINT) {
        // handle most cases here (ch is a BMP code point or a
        // negative value (invalid code point))
        //在这里其实已经处理了大多数情况
        final char[] value = this.value;
        //3. 从fromIndex开始,循环,找到第一个与ch相等的进行返回
        for (int i = fromIndex; i < max; i++) {
            if (value[i] == ch) {
                return i;
            }
        }
        return -1;
    } else {
        //4. 罕见字符处理
        return indexOfSupplementary(ch, fromIndex);
    }
}
```

  再来分析indexOf(String str, int fromIndex),该方法功能是从指定的索引处开始，返回第一次出现的指定子字符串在此字符串中的索引.

  大体思路:

  1. 有点类似于字符串查找子串,先在当前字符串中找到与目标字符串的第一个字符相同的索引处
  2. 再从此索引出发循环遍历目标字符串后面的字符.
  3. 如果全部相同,则返回下标;如果不全部相同,则重复步骤1

  文字可能描述不清楚,上图片

  ![](http://olg7c0d2n.bkt.clouddn.com/18-4-20/22473007.jpg)

  我们要在beautifulauful中查找ful,那么步骤是首先找到f,再匹配后面的`ul`部分,找到则返回索引,未找到则继续查找.

```java
public int indexOf(String str, int fromIndex) {
    return indexOf(value, 0, value.length,
            str.value, 0, str.value.length, fromIndex);
}

//在source数组中查找target数组
static int indexOf(char[] source, int sourceOffset, int sourceCount,
        char[] target, int targetOffset, int targetCount,
        int fromIndex) {
    //1. 校验参数合法性
    if (fromIndex >= sourceCount) {
        return (targetCount == 0 ? sourceCount : -1);
    }
    if (fromIndex < 0) {
        fromIndex = 0;
    }
    if (targetCount == 0) {
        return fromIndex;
    }

    //2. 记录第一个需要匹配的字符
    char first = target[targetOffset];
    //3. 这一次匹配的能到达的最大索引
    int max = sourceOffset + (sourceCount - targetCount);

    //4. 循环遍历后面的数组
    for (int i = sourceOffset + fromIndex; i <= max; i++) {
        /* Look for first character. */
        //5. 循环查找,直到查找到第一个和目标字符串第一个字符相同的索引
        if (source[i] != first) {
            while (++i <= max && source[i] != first);
        }

        /* Found first character, now look at the rest of v2 */
        //6. 找到了第一个字符,再来看看目标字符串剩下的部分
        if (i <= max) {
            int j = i + 1;
            int end = j + targetCount - 1;
            //7. 匹配一下目标字符串后面的字符串是否相等  不相等的时候就跳出循环
            for (int k = targetOffset + 1; j < end && source[j]
                    == target[k]; j++, k++);
            //8. 如果全部相等,则返回索引
            if (j == end) {
                /* Found whole string. */
                return i - sourceOffset;
            }
        }
    }
    return -1;
}

```

- **lastIndexOf(int ch/String str)**

  该方法与第一种类似，区别在于该方法从字符串的末尾位置向前查找.

  实现方法也与第一种是类似的,只不过是从后往前查找.

```java
public int lastIndexOf(int ch) {
    return lastIndexOf(ch, value.length - 1);
}
public int lastIndexOf(int ch, int fromIndex) {
    //1. 判断是否是罕见字符
    if (ch < Character.MIN_SUPPLEMENTARY_CODE_POINT) {
        // handle most cases here (ch is a BMP code point or a
        // negative value (invalid code point))
        final char[] value = this.value;
        //2. 从fromIndex(从哪个索引开始), value.length - 1(数组最后一个索引)中小一点的往前找,这里之所以这样做是因为fromIndex可能比value.length-1大.这里求最小值就可以覆盖所有情况,不管fromIndex和value.length-1谁大.
        int i = Math.min(fromIndex, value.length - 1);
        //3. 循环 逐个字符进行比较,找到则返回索引
        for (; i >= 0; i--) {
            if (value[i] == ch) {
                return i;
            }
        }
        return -1;
    } else {
      //4. 罕见字符处理
        return lastIndexOfSupplementary(ch, fromIndex);
    }
}
```

- **lastIndexOf(int ch/String str, int fromIndex)**

  该方法与第二种方法类似，区别在于该方法从fromIndex位置向前查找.
  
  实现思路:这里要稍微复杂一点,相当于从后往前查找指定子串.上图吧
  
  ![](http://olg7c0d2n.bkt.clouddn.com/18-4-20/13862104.jpg)

  图画的有点丑,哈哈. 假设我们需要在`StringBuffer`中查找`ABuff`中的子串`Buff`,因为`Buff`的长度是4,所以我们最大的索引可能值是图中的rightIndex.然后我们就开始在source数组中匹配目标字符串的最后一个字符,匹配到后,再逐个字符进行比较剩余的字符,如果全部匹配,则返回索引.未全部匹配,则再次在source数组中寻找与目标字符串最后一个字符相等的字符,然后找到后继续匹配除去最后一个字符剩余的字符串.  唉~叙述的不是特别清晰,看代码吧,代码比我说的清晰..

```java
public int lastIndexOf(String str, int fromIndex) {
    return lastIndexOf(value, 0, value.length,
            str.value, 0, str.value.length, fromIndex);
}

static int lastIndexOf(char[] source, int sourceOffset, int sourceCount,
        char[] target, int targetOffset, int targetCount,
        int fromIndex) {
    /*
     * Check arguments; return immediately where possible. For
     * consistency, don't check for null str.
     */
     //1. 最大索引的可能值
    int rightIndex = sourceCount - targetCount;
    //2. 参数合法性检验
    if (fromIndex < 0) {
        return -1;
    }
    if (fromIndex > rightIndex) {
        fromIndex = rightIndex;
    }
    /* Empty string always matches. */
    if (targetCount == 0) {
        return fromIndex;
    }

    //3. 记录目标字符串最后一个字符索引处和该字符内容
    int strLastIndex = targetOffset + targetCount - 1;
    char strLastChar = target[strLastIndex];
    //4. 只需要遍历到min处即可停止遍历了,因为在min前面的字符数量已经小于目标字符串的长度了
    int min = sourceOffset + targetCount - 1;
    //5. strLastChar在source中的最大索引
    int i = min + fromIndex;

//这里的语法不是很常见,有点类似于goto,平时我们在使用时尽量不采用这种方式,这种方式容易降低代码的可读性,而且容易出错.
startSearchForLastChar:   
    while (true) {
        //6. 在有效遍历区间内,循环查找第一个与目标字符串最后一个字符相等的字符,如果找到,则跳出循环,该字符的索引是i
        while (i >= min && source[i] != strLastChar) {
            i--;
        }
        //7. 如果已经小于min了,那么说明没找到,直接返回-1
        if (i < min) {
            return -1;
        }
        //8. 找到了,则再进行查找目标字符串除去最后一个字符剩下的子串
        //从最后一个字符的前一个字符开始查找
        int j = i - 1;
        //9. 目标字符串除去最后一个字符剩下的子串长度是targetCount - 1,此处start是此次剩余子串查找能到达的最小索引处
        int start = j - (targetCount - 1);
        //10. 记录目标字符串的倒数第二个字符所在target中的索引
        int k = strLastIndex - 1;

        //11. 循环查找剩余子串是否全部字符相同
        //不相同则直接跳出继续第6步
        //全部相同则返回索引
        while (j > start) {
            if (source[j--] != target[k--]) {
                i--;
                continue startSearchForLastChar;
            }
        }
        return start - sourceOffset + 1;
    }
}

```
### 8.字符串中字符的替换

- **replace(char oldChar, char newChar)**

  功能:用字符newChar替换当前字符串中所有的oldChar字符，并返回一个新的字符串.
  大体思路:
  
  1. 首先判断oldChar与newChar是否相同,相同的话就没必要进行后面的操作了
  2. 从最前面开始匹配与oldChar相匹配的字符,记录索引为i
  3. 如果上面的i是正常范围内(小于len),新建一个数组,长度为len(原来的字符串的长度),将i索引前面的字符逐一复制进新数组里面,然后循环 `i<=x<len` 的字符,将字符逐一复制进新数组,但是这次的复制有规则,即如果那个字符与oldChar相同那么新数组对应索引处就放newChar.
  4. 最后通过新建的数组new一个String对象返回
  
  **思考**:一开始我觉得第二步好像没什么必要性,没有第二步其实也能实现.但是,仔细想想,假设原字符串没有查找到与oldChar匹配的字符,那么我们就可以规避去新建一个数组,从而节约了不必要的开销.可以,很棒,我们就是要追求极致的性能,减少浪费资源.
  
  **小细节**:源码中有一个小细节,注释中有一句`avoid getfield opcode`,意思是避免getfield操作码?
  ![](http://olg7c0d2n.bkt.clouddn.com/18-4-20/58741120.jpg)
  感觉那句代码就是拷贝了一个引用副本啊,有什么高大上的作用?查阅文章https://blog.csdn.net/gaopu12345/article/details/52084218 后发现答案:在一个方法中需要大量引用实例域变量的时候，使用方法中的局部变量代替引用可以减少getfield操作的次数，提高性能。
  
```java
public String replace(char oldChar, char newChar) {
    //1. 如果两者相同,那么就没必要进行比较了
    if (oldChar != newChar) {
        int len = value.length;
        int i = -1;
        char[] val = value; /* avoid getfield opcode */

        //2. 从最前面开始,循环遍历,找到与oldChar相同的字符
        while (++i < len) {
            if (val[i] == oldChar) {
                break;
            }
        }
        //3. 如果找到了与oldChar相同的字符才进入if
        if (i < len) {
            //4. 新建一个数组,用于存放新数据
            char buf[] = new char[len];
            //5. 将i前面的全部复制进新数组里面去
            for (int j = 0; j < i; j++) {
                buf[j] = val[j];
            }
            //6. 在i后面的字符,我们将其一个一个地放入新数组中,当然在放入时需要比对是否和oldChar相同,相同则存放newChar
            while (i < len) {
                char c = val[i];
                buf[i] = (c == oldChar) ? newChar : c;
                i++;
            }
            //7. 最终重新new一个String
            return new String(buf, true);
        }
    }
    return this;
}
```
### 9.其他类方法

- **trim()**

    功能:截去字符串两端的空格，但对于中间的空格不处理
    大体实现:记录前面有st个空格,最后有多少个空格,那么长度就减去多少个空格,最后根据上面的这2个数据去切割字符串.
```java
public String trim() {
    int len = value.length;
    int st = 0;
    char[] val = value;    /* avoid getfield opcode */

    //1. 记录前面有多少个空格
    while ((st < len) && (val[st] <= ' ')) {
        st++;
    }
    //2. 记录后面有多少个空格
    while ((st < len) && (val[len - 1] <= ' ')) {
        len--;
    }
    //3. 切割呗,注意:切割里面具体实现是重新new了一个String
    return ((st > 0) || (len < value.length)) ? substring(st, len) : this;
}
```

- **startsWith(String prefix)或endsWith(String suffix)**

    功能:用来比较当前字符串的起始字符或子字符串prefix和终止字符或子字符串suffix是否和当前字符串相同，重载方法中同时还可以指定比较的开始位置offset.

    思路:比较简单,就直接看代码了,有详细注释.

```java
public boolean startsWith(String prefix) {
    return startsWith(prefix, 0);
}
public boolean startsWith(String prefix, int toffset) {
    char ta[] = value;
    int to = toffset;
    char pa[] = prefix.value;
    int po = 0;
    int pc = prefix.value.length;
    // Note: toffset might be near -1>>>1.
    //1. 入参检测合法性
    if ((toffset < 0) || (toffset > value.length - pc)) {
        return false;
    }
    //2. 循环进行逐个字符遍历,有不相等的就直接返回false,遍历完了还没发现不相同的,那么就是true
    while (--pc >= 0) {
        if (ta[to++] != pa[po++]) {
            return false;
        }
    }
    return true;
}
```

- **contains(String str)**

    功能:判断参数s是否被包含在字符串中，并返回一个布尔类型的值.
    思路:其实就是利用已经实现好的indexOf()去查找是否包含.源码中对于已实现的东西利用率还是非常高的.我们要多学习.
```java
public boolean contains(CharSequence s) {
    return indexOf(s.toString()) > -1;
}
```

### 10.基本类型转换为字符串类型

> 这部分代码一看就懂,都是一句代码解决.

```java
public static String valueOf(Object obj) {
    return (obj == null) ? "null" : obj.toString();
}
public static String valueOf(char data[]) {
    return new String(data);
}
public static String valueOf(char data[], int offset, int count) {
    return new String(data, offset, count);
}
public static String copyValueOf(char data[], int offset, int count) {
    return new String(data, offset, count);
}
public static String copyValueOf(char data[]) {
    return new String(data);
}
public static String valueOf(boolean b) {
    return b ? "true" : "false";
}
public static String valueOf(char c) {
    char data[] = {c};
    return new String(data, true);
}
public static String valueOf(int i) {
    return Integer.toString(i);
}
public static String valueOf(long l) {
    return Long.toString(l);
}
public static String valueOf(float f) {
    return Float.toString(f);
}
public static String valueOf(double d) {
    return Double.toString(d);
}
```

### 注意事项

**最后注意一下:Android 6.0（23） 源码中，String类的实现被替换了，具体调用的时候，会调用一个StringFactory来生成一个String.**
来看下Android源码中String,,我擦,,这.....直接抛错误`UnsupportedOperationException`,可能是因为Oracle告Google的原因吧..
```java
public String() {
    throw new UnsupportedOperationException("Use StringFactory instead.");
}
public String(String original) {
    throw new UnsupportedOperationException("Use StringFactory instead.");
}
```

我们平时开发APP时都是使用的java.lang包下面的String,上面的问题一般不会遇到,但是作为Android开发者还是要了解一下.

## 三.AbstractStringBuilder源码分析

先看看类StringBuffer和StringBuilder的继承结构

![](http://olg7c0d2n.bkt.clouddn.com/18-4-17/57996290.jpg)

> 可以看到StringBuffer和StringBuilder都是继承了AbstractStringBuilder.所以这里先分析一下AbstractStringBuilder.

在这基类里面真实的保存了StringBuffer和StringBuilder操作的实际数据内容,数据内容其实是一个`char[] value;`数组,在其构造方法中其实就是初始化该字符数组.

```java
char[] value;
AbstractStringBuilder() {
}
AbstractStringBuilder(int capacity) {
    value = new char[capacity];
}
```

### 1.扩容
既然数据内容(上面的value数组)是在AbstractStringBuilder里面的,那么很多操作我觉得应该也是在父类里面,比如扩容,下面我们看看源码

```java
public void ensureCapacity(int minimumCapacity) {
    if (minimumCapacity > 0)
        ensureCapacityInternal(minimumCapacity);
}

/**
* 确保value字符数组不会越界.重新new一个数组,引用指向value
*/    
private void ensureCapacityInternal(int minimumCapacity) {
    // overflow-conscious code
    if (minimumCapacity - value.length > 0) {
        value = Arrays.copyOf(value,
                newCapacity(minimumCapacity));
    }
}

/**
* 扩容:之前的大小的2倍+2
*/    
private int newCapacity(int minCapacity) {
    // overflow-conscious code   扩大2倍+2
    //小知识点:这里可能会溢出,溢出后是负数哈,注意
    int newCapacity = (value.length << 1) + 2;
    if (newCapacity - minCapacity < 0) {
        newCapacity = minCapacity;
    }
    //MAX_ARRAY_SIZE的值是Integer.MAX_VALUE - 8,先判断一下预期容量(newCapacity)是否在0<x<MAX_ARRAY_SIZE之间,在这区间内就直接将数值返回,不在这区间就去判断一下是否溢出
    return (newCapacity <= 0 || MAX_ARRAY_SIZE - newCapacity < 0)
        ? hugeCapacity(minCapacity)
        : newCapacity;
}

/**
* 判断大小  是否溢出
*/
private int hugeCapacity(int minCapacity) {
    if (Integer.MAX_VALUE - minCapacity < 0) { // overflow
        throw new OutOfMemoryError();
    }
    return (minCapacity > MAX_ARRAY_SIZE)
        ? minCapacity : MAX_ARRAY_SIZE;
}
```
可以看到这里的扩容方式是 = 以前的大小*2+2,其他的细节方法中已给出详细注释.

### 2.追加

举一个比较有代表性的添加,详细注释在代码中

```java
/**
* 追加:从指定字符串的片段
*/
public AbstractStringBuilder append(CharSequence s, int start, int end) {
    //1. 如果是空,则添加字符串"null"
    if (s == null)
        s = "null";
    //2. 判断是否越界
    if ((start < 0) || (start > end) || (end > s.length()))
        throw new IndexOutOfBoundsException(
            "start " + start + ", end " + end + ", s.length() "
            + s.length());
    //3. 记录添加字符串长度
    int len = end - start;
    //4. 判断一下 当前数组长度+需要添加的字符串长度 是否够装,不够装就扩容(扩容时还有复制原内容到新数组中)
    ensureCapacityInternal(count + len);
    //5. 追加内容到value数组最后
    for (int i = start, j = count; i < end; i++, j++)
        value[j] = s.charAt(i);
    //6. 更新数组长度
    count += len;
    return this;
}
```

### 3.增加

这里的大体思想是和以前大一的时候用C语言在数组中插入数据是一样的.

这里假设需要插入的字符串s,插入在目标字符串desOffset处,插入的长度是len.首先将需要插入处的desOffset~desOffset+len往后挪,挪到desOffset+len处,然后在desOffset处插入目标字符串.

大体思想就是这样,是不是觉得很熟悉?? `ヽ(￣▽￣)ﾉ`

下面这个方法是上面思路的具体实现,详细的逻辑分析已经放到代码注释中.

```java
//插入字符串,从dstOffset索引处开始插入,插入内容为s中的[start,end]字符串
public AbstractStringBuilder insert(int dstOffset, CharSequence s,
                                         int start, int end) {
    //1. 空处理
    if (s == null)
        s = "null";
    //2. 越界判断
    if ((dstOffset < 0) || (dstOffset > this.length()))
        throw new IndexOutOfBoundsException("dstOffset "+dstOffset);
    //3. 入参检测是否合法
    if ((start < 0) || (end < 0) || (start > end) || (end > s.length()))
        throw new IndexOutOfBoundsException(
            "start " + start + ", end " + end + ", s.length() "
            + s.length());
    //4. 长度记录
    int len = end - start;
    //5. 判断一下 当前数组长度+需要添加的字符串长度 是否够装,不够装就扩容(扩容时还有复制原内容到新数组中)
    ensureCapacityInternal(count + len);
    //6. 将原数组中dstOffset开始的count - dstOffset个字符复制到dstOffset + len处,,,,这里其实就是腾出一个len长度的区间,用用户存放目标字符串,这个区间就是dstOffset到dstOffset + len
    System.arraycopy(value, dstOffset, value, dstOffset + len,
                     count - dstOffset);
    //7. 存放目标字符串
    for (int i=start; i<end; i++)
        value[dstOffset++] = s.charAt(i);
    //8. 记录字符串长度
    count += len;
    //9. 返回自身引用  方便链式调用
    return this;
}
```

### 4.删除

源码里面的删除操作实际上是复制,比如下面这个方法删除start到end之间的字符,实际是将以end开始的字符复制到start处,**并且将数组的长度记录count减去len个**

```java
//删除从start到end索引区间( [start,end)前闭后开区间 )内内容
public AbstractStringBuilder delete(int start, int end) {
    if (start < 0)
        throw new StringIndexOutOfBoundsException(start);
    if (end > count)
        end = count;
    if (start > end)
        throw new StringIndexOutOfBoundsException();
    int len = end - start;
    //当start==end时不会改变
    if (len > 0) {
      //将value数组的start+len位置开始的count-end个字符复制到value数组的start位置处.  注意,并且将数组count减去len个.
        System.arraycopy(value, start+len, value, start, count-end);
        count -= len;
    }
    return this;
}
```

### 5.切割

我擦,,,,原来StringBuffer的切割效率并不高嘛,其实就是new了一个String....

```java
public String substring(int start, int end) {
    if (start < 0)
        throw new StringIndexOutOfBoundsException(start);
    if (end > count)
        throw new StringIndexOutOfBoundsException(end);
    if (start > end)
        throw new StringIndexOutOfBoundsException(end - start);
    return new String(value, start, end - start);
}
```

### 6.改

改其实就是对其替换,而在源码中替换最终的实现其实是复制(还是复制..`(￣▽￣)~*`).

大体思路: 假设需要将字符串str替换value数组中的start-end中,这时只需将end后面的字符往后移动,在中间腾出一个坑,用于存放需要替换的str字符串.最后将str放到value数组中start索引处.

```java
public AbstractStringBuilder replace(int start, int end, String str) {
    //1. 入参检测合法性
    if (start < 0)
        throw new StringIndexOutOfBoundsException(start);
    if (start > count)
        throw new StringIndexOutOfBoundsException("start > length()");
    if (start > end)
        throw new StringIndexOutOfBoundsException("start > end");
    if (end > count)
        end = count;
    //2. 目标String长度
    int len = str.length();
    //3. 计算新的数组的长度
    int newCount = count + len - (end - start);
    //4. 判断一下是否需要扩容
    ensureCapacityInternal(newCount);

    //5. 将value数组的end位置开始的count - end个字符复制到value数组的start+len处. 相当于把end之后的字符移到最后去,然后中间留个坑,用来存放str(需要替换成的值)
    System.arraycopy(value, end, value, start + len, count - end);
    //6. 这是String的一个方法,用于将str复制到value中start处  其最底层实现是native方法(getCharsNoCheck() )
    str.getChars(value, start);
    //7. 更新count
    count = newCount;
    return this;
}
```

### 7.查询

查询是最简单的,就是返回数组中相应索引处的值.

```java
public char charAt(int index) {
    if ((index < 0) || (index >= count))
        throw new StringIndexOutOfBoundsException(index);
    return value[index];
}
```

## 四.StringBuffer源码分析

定义

```java
public final class StringBuffer
    extends AbstractStringBuilder
    implements java.io.Serializable, CharSequence
```

StringBuffer和StringBuilder都是相同的继承结构.都是继承了AbstractStringBuilder.

StringBuffer和StringBuilder构造方法,可以看到默认大小是16,
```java
public StringBuffer() {
    super(16);
}
public StringBuffer(int capacity) {
    super(capacity);
}
```

### 1. 我们先来看看StringBuffer的append方法

啥,不就是调用父类的append方法嘛..
![](http://olg7c0d2n.bkt.clouddn.com/18-4-20/79950568.jpg)

但是,请 **注意:前面说了StringBuffer是线程安全的,为什么,源码里面使用了synchronized给方法加锁了.**

```java
public synchronized StringBuffer append(boolean b) {
    toStringCache = null;
    super.append(b);
    return this;
}

@Override
public synchronized StringBuffer append(char c) {
    toStringCache = null;
    super.append(c);
    return this;
}

@Override
public synchronized StringBuffer append(int i) {
    toStringCache = null;
    super.append(i);
    return this;
}
```

### 2.StringBuffer的其他方法

几乎都是所有方法都加了synchronized,几乎都是调用的父类的方法.

```java
public synchronized StringBuffer delete(int start, int end) {
    toStringCache = null;
    super.delete(start, end);
    return this;
}
public synchronized StringBuffer replace(int start, int end, String str) {
    toStringCache = null;
    super.replace(start, end, str);
    return this;
}
public synchronized int indexOf(String str, int fromIndex) {
    return super.indexOf(str, fromIndex);
}
...
```

## 五.StringBuilder分析

定义
```java
public final class StringBuilder
    extends AbstractStringBuilder
    implements java.io.Serializable, CharSequence
```

### 1. 我们先来看看StringBuilder的append方法

啥,还是调用父类的append方法嘛..
![](http://olg7c0d2n.bkt.clouddn.com/18-4-20/92067984.jpg)

但是,请 **注意:前面说了StringBuilder不是线程安全的,为什么,源码里面没有使用synchronized进行加锁.**

```java
public StringBuilder append(boolean b) {
    super.append(b);
    return this;
}

@Override
public StringBuilder append(char c) {
    super.append(c);
    return this;
}

@Override
public StringBuilder append(int i) {
    super.append(i);
    return this;
}
```

### 2.StringBuilder的其他方法

也是全部调用的父类方法.  但是是没有加锁的.

```java
public StringBuilder delete(int start, int end) {
    super.delete(start, end);
    return this;
}
public StringBuilder replace(int start, int end, String str) {
    super.replace(start, end, str);
    return this;
}
public int indexOf(String str) {
    return super.indexOf(str);
}
...
```

## 六.总结

1. String,StringBuffer,StringBuilder最终底层存储与操作的都是char数组.但是String里面的char数组是final的,而StringBuffer,StringBuilder不是,也就是说,String是不可变的,想要新的字符串只能重新生成String.而StringBuffer和StringBuilder只需要修改底层的char数组就行.相对来说,开销要小很多.
2. String的大多数方法都是重新new一个新String对象返回,频繁重新生成容易生成很多垃圾.
3. 还是那句古话,StringBuffer是线程安全的,StringBuilder是线程不安全的.因为StringBuffer的方法是加了synchronized锁起来了的,而StringBuilder没有.
4. 增删比较多时用StringBuffer或StringBuilder（注意单线程与多线程）。实际情况按需而取吧，既然已经知道了里面的原理。

### 学习源码我们能从中收获什么

- Java的源码都是经过上千万(我乱说的..哈哈)的程序员校验过的,不管是算法、命名、doc文档、写作风格等等都非常规范，值得我们借鉴与深思。还有很多很多的小技巧。

- 下次在使用时能按需而取，追求性能。
- 避免项目中的很多错误的发生。