# Challenge#7 Steal all ETH in the exchange
<details>
<summary> Hint </summary>
<p>

```
While poking around a web service of one of the most popular 
DeFi projects in the space, you get a somewhat strange response 
from their server. This is a snippet:
  
  HTTP/2 200 OK
          content-type: text/html
          content-language: en
          vary: Accept-Encoding
          server: cloudflare

          4d 48 68 6a 4e 6a 63 34 5a 57 59 78 59 57 45 30 4e 54 5a 6b 59 54 59 31 59 7a 5a 6d 59 7a 55 34 4e 6a 46 6b 4e 44 51 34 4f 54 4a 6a 5a 47 5a 68 59 7a 42 6a 4e 6d 4d 34 59 7a 49 31 4e 6a 42 69 5a 6a 42 6a 4f 57 5a 69 59 32 52 68 5a 54 4a 6d 4e 44 63 7a 4e 57 45 35

          4d 48 67 79 4d 44 67 79 4e 44 4a 6a 4e 44 42 68 59 32 52 6d 59 54 6c 6c 5a 44 67 34 4f 57 55 32 4f 44 56 6a 4d 6a 4d 31 4e 44 64 68 59 32 4a 6c 5a 44 6c 69 5a 57 5a 6a 4e 6a 41 7a 4e 7a 46 6c 4f 54 67 33 4e 57 5a 69 59 32 51 33 4d 7a 59 7a 4e 44 42 69 59 6a 51 34
```
</p>
</details>

Looking at contracts, **_TrustfulOracleInitializer_**  doesn't perform much in this context. 

**_TrustfulOracle_** once deployed, call `setupInitialPrices()` that can only called once refer `renounceRole` from [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControlEnumerable.sol). Price is updated through `postPrice()` where the price is calculated through `_computeMedianPrice()`. Median price example in this case, we have 3 oracle source, the function will sort the price and the median price would be the one in the middle, however if the sources were even number `if (prices.length % 2 == 0)`, we run the calculation inside the function instead.

**_Exchange_** can be summarized as `buyOne()` and `sellOne()` functions which buy and sell DVNFT.

Overall, mostly the functions has nothing critically exploitable. The only thing left is the hint. Looking back at hint the character looks like hexadecimal byte. After converting back to its raw value it looks like a bunch of random characters.

Maybe...it could be private keys? Since the title is "Compromised", the character should resemblance something useful like perhaps private key? These random characters should be base64 encoded, let decoded it with base64. We have the [output](https://cyberchef.org/#recipe=Fork('%5C%5Cn','%5C%5Cn',false)From_Hex('Auto')From_Base64('A-Za-z0-9%2B/%3D',true,false)&input=NGQgNDggNjggNmEgNGUgNmEgNjMgMzQgNWEgNTcgNTkgNzggNTkgNTcgNDUgMzAgNGUgNTQgNWEgNmIgNTkgNTQgNTkgMzEgNTkgN2EgNWEgNmQgNTkgN2EgNTUgMzQgNGUgNmEgNDYgNmIgNGUgNDQgNTEgMzQgNGYgNTQgNGEgNmEgNWEgNDcgNWEgNjggNTkgN2EgNDIgNmEgNGUgNmQgNGQgMzQgNTkgN2EgNDkgMzEgNGUgNmEgNDIgNjkgNWEgNmEgNDIgNmEgNGYgNTcgNWEgNjkgNTkgMzIgNTIgNjggNWEgNTQgNGEgNmQgNGUgNDQgNjMgN2EgNGUgNTcgNDUgMzUKCjRkIDQ4IDY3IDc5IDRkIDQ0IDY3IDc5IDRlIDQ0IDRhIDZhIDRlIDQ0IDQyIDY4IDU5IDMyIDUyIDZkIDU5IDU0IDZjIDZjIDVhIDQ0IDY3IDM0IDRmIDU3IDU1IDMyIDRmIDQ0IDU2IDZhIDRkIDZhIDRkIDMxIDRlIDQ0IDY0IDY4IDU5IDMyIDRhIDZjIDVhIDQ0IDZjIDY5IDVhIDU3IDVhIDZhIDRlIDZhIDQxIDdhIDRlIDdhIDQ2IDZjIDRmIDU0IDY3IDMzIDRlIDU3IDVhIDY5IDU5IDMyIDUxIDMzIDRkIDdhIDU5IDdhIDRlIDQ0IDQyIDY5IDU5IDZhIDUxIDM0). Looks exactly like private key! 

To confirm what is it, we use [this tool](https://eth-toolbox.com/) to check the public address of this private key. We have these:
```
Output: 
0x81a5d6e50c214044be44ca0cb057fe119097850c
0xe92401a4d3af5e446d93d11eec806b1462b39d15
```
Exactly the public address of 2 among 3 of the oracle source. This make our exploitation much clearer now. We can gain access through the oracle source to:
1. Manipulate NFT price from 2 source
2. Buy at low price
3. Set oracle price to absurdly high price
4. Sell at high price
5. Set back to original price  
