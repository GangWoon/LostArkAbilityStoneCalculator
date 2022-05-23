# LostArkAbilityStoneCalculator
[시연영상](https://youtube.com/shorts/t8NvJEWxVyg?feature=share) 
- 화면(어두운 테마)
![Untitled-2022-03-14-2112-11](https://user-images.githubusercontent.com/48466830/165133409-a22e9f15-31f3-4a35-8159-858740bdd657.png)

<br>

<br>

<br>

- 화면 설계도

![Untitled-2022-03-14-2112-8](https://user-images.githubusercontent.com/48466830/165128418-5f158197-e8f0-4eb3-be98-52e3f1f032c6.png)

<br>

<br>

<br>

- 시간 흐름도

![Untitled-2022-03-14-2112-9](https://user-images.githubusercontent.com/48466830/165128511-7c39ba00-9e09-4be9-bfb5-bfd2cce66538.png)

<br>

---

<br>

<br>

<br>

### 해결했던 문제들

**- 스트림 분리**

계산기에서 확률 계산이 끝난걸 Store에서 어떻게 받아야할지 고민했었습니다.

Store 입장에서는 계산기 내부 상태에 대해서 신경쓸 필요 없이, 외부로 노출된 Publisher에만 의존해서 상태값을 체크하는 형태로 해결했습니다.

![Untitled-2022-03-14-2112-10](https://user-images.githubusercontent.com/48466830/165130803-255f5cb9-b29a-4833-9896-b1648e6676f2.png)

<br>

<br>

**- @Published 잘못된 사용**

초기 값을 방출하는지 몰랐을 때, 아래와 같이 접근해서 문제를 해결하려고 했습니다.
다른 분의 피드백으로 해당 속성을 구독했을때 문제가 있음을 확인한 후 dropFirst()를 통해서 문제를 해결했습니다.

<br>

~~**- 큰 데이터를 다루는 방법** [issue](https://github.com/GangWoon/LostArkAbilityStoneCalculator/issues/3)~~

~~알고리즘 결과 값이 상당히 큰 메모리를 차지합니다. ~~

~~이를 set하고 난 직후 해당 값을 접근했을때 set이 되지 않는 문제가 있었습니다.~~

~~이 문제는 해당 값이 set이 될 동안 Error를 발생시켜서 준비가 될때 까지 기다리는 형태로 해결했습니다.~~



<br>

<br>

<br>

---

### Reference

Designer: Gavii

Architecture: TCA

Algorithm: https://heehoon.kim/dolpago (Heehoon Kim)
