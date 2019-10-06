Tack för att du hjälpa till!
Den här sidan beskriver hur du kan hjälpa till med att lägga till stöd för resursbokning för din skola.

Gå till hemsidan för att boka resurser. Det är oftast skolans vanliga hemsida, fast med "kronox." innan, till exempel så skulle "mdh.se" bli "kronox.mdh.se". Logga sedan in och gå till "resursbokning" fliken. Där borde du se alla olika grupprum som flikar nära toppen av sidan. Högerklicka sedan varsomhelst på sidan och klicka på knappen för att visa sidans källkod. Försök att hitta en sektion som ungefär ser ut som:
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
En av de lättaste sätten att hitta den delen är att söka på "current". Kopiera sedan den delen och skapa en issue här på GitHub eller skicka ett email till mig (kan hittas på Google Play sidan) med informationen samt namnet på din skola så blir det tillagt inom kort. Tack för hjälpen!