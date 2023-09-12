import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";

const Home = () => {
  return (
    <h4>Hello World!</h4>
  )
}

const Page1 = () => {
  return (
    <h4>Page1!</h4>
  )
}

function App() {
  return (
    <Router basename="/">
      <Link to="/">Home</Link>
      <Link to="/page1">Page1</Link>
      <Routes>
      <Route path="/" Component={Home}/>
      <Route path="/page1" Component={Page1}/>
      </Routes>

    </Router>
  );
}

export default App;
