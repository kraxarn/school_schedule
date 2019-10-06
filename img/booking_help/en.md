Thank you for wanting to help out!
This page will describe how you can help out with adding support for resource booking for your school.

Go to the website for booking resources. This is usually the normal school website prefixed with "kronox.", for example "mdh.se" would be "kronox.mdh.se". Then, login and go to the "resource booking" tab. You should see the available resources to book as tabs near the top. Next, right click and select to view the "page source". You want to look for a section that looks like this:
```html
<div class="nav">
  <ul class="menu">
    <li class='current'>
      <a href="/resursbokning.jsp?flik=FLIK_0000"><em><b>
        Grupprum Eskilstuna</b></em></a>
    </li>
    <li class='tab'>
      <a href="/resursbokning.jsp?flik=FLIK_0001"><em><b>
        Grupprum Västerås</b></em></a>
    </li>
    <li class='tab'>
      <a href="/resursbokning.jsp?flik=FLIK_0005"><em><b>
        Kammarmusiken Slottet (end för sång och musik kurser)</b></em></a>
    </li>	
  </ul>
</div>
```
One of the easiest ways to find it is to search for "current". Next, copy that section and either open an issue here on GitHub or send me an email (can be found on the Google Play page) with the information together with the school name and it will be added in the next update. Thanks for your help!