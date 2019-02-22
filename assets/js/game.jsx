import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { Stage, Layer, Image, Container, Rect, Line, Text } from 'react-konva';
import useImage from 'use-image';
import spaceShipImg from '../static/images/spaceship.svg';
import alienImage from '../static/images/enemy1.svg';

export default function game_init(root, channel) {
  console.log('game_init', root)
  ReactDOM.render(<Game channel={channel}/>, root);
}

const SpaceshipImage = (props) => {
  const [image] = useImage(spaceShipImg);
  return <Image {...{
    ...props,
    offsetX: 20,
    offsetY: 25,
    image: image,
    height: 50,
    width: 40,
  }}/>
}

const AlienImage = (props) => {
  const [image] = useImage(alienImage)
  return <Image {...{
    ...props,
    offsetX: 20,
    offsetY: 25,
    image: image,
    height: 60,
    width: 45,
    rotation: 180}}/>
}

class Game extends React.Component {
  constructor(props) {
    const { channel } = props;
    super(props);
    this.state = {
      aliens: [],
      barriers: [],
      lasers: [],
      players: [],
      alien_lasers: [],
      over: false
    };
    window.channel = channel
    this.onKeyDown = this.onKeyDown.bind(this)
    window.keysEnabled = false
  }

  enableKeys() {
    window.keysEnabled = true
    document.addEventListener("keydown", this.onKeyDown)
    document.addEventListener("keydown", this.onRestart)
  }

  componentDidMount(){
      window.channel.join("space_raiders").receive("ok", () => {}).receive("error", resp => console.log(resp))
      window.onunload = () => window.channel.push("disconnect", {id: window.id})
      window.channel.on('new_tick', msg => {
        const { players } = msg
        let thisPlayer = players.find((player) => player.name == window.userName);
        window.id = thisPlayer.id
        this.setState(msg)
        if(thisPlayer.dead){
          window.keysEnabled = false
          document.removeEventListener("keydown", this.onKeyDown)
        } else if(window.id != undefined && !window.keysEnabled){
          this.enableKeys()
        }
   })
  }



  renderPlayerLasers(lasers) {
    const out = [];
    const points = [0, 0, 0, -20]
    if(lasers[0]) console.log(lasers[0].posn.x, lasers[0].posn.y)
    lasers.forEach((laser) => {
      if(laser.inplay) {
        out.push(<Line {...{x: (laser.posn.x * 1.5), y: laser.posn.y * 3, points, stroke: "black"}}/>)
      }
    })
    return out;
  }

  renderAlienLasers(lasers){
    const out = [];
    const points = [0,0, 0,20]
    lasers.forEach((laser) => {
       out.push(<Line {...{x: (laser.x * 1.5), y: laser.y * 3, points, stroke: "red"}}/>)
    })
    return out;
  }

  onRestart(e) {
   if (e.key == "r") {
          window.channel.push("restart").receive("ok", (game) => {this.setState(game.game);})
    }
  }

  onKeyDown(e) {
    const { key } = e;
    if (key == "e"){
          window.channel.push("fire", {id: window.id}).receive("ok", (game) => {this.setState(game.game);})
    } else if (key == "ArrowLeft" || key == "a") {
          window.channel.push("move", {id: window.id, direction: "left"}).receive("ok", (game) => {this.setState(game.game);})
    } else if (e.key == "ArrowRight" || key == "d") {
          window.channel.push("move", {id: window.id, direction: "right"}).receive("ok", (game) => {this.setState(game.game)})
    }
  }

  renderAliens(aliens){
    const out = [];
    aliens.forEach((alien) => {
      out.push(<AlienImage {...{x: (alien.posn.x *1.5), y: alien.posn.y * 3}}/>);
    })
    return out;
  }


  renderBarriers(barriers){
    const out = [];
    barriers.forEach((barrier) => {
      out.push(<Rect {...{
        offsetX: 45,
        offsetY: 15,
        y: barrier.posn.y * 3,
        x: (barrier.posn.x * 1.5) ,
        height: 30,
        width: 90,
        fill: 'black'}}/>)
    })
    return out;
  }

  renderEndText(){
    const {aliens} = this.state
    if(aliens.length == 0) {
      return(<Text {...{fontsize: 20, text: "You Won!", x: 450, y: 500, width: 200}}/>)
    }
    return(<Text {...{fontsize: 20, text: "You Lost", x: 450, y: 500}}/>)
    }

  renderPlayers(players) {
    const out = [];
    players.forEach((player) => {
      if(!player.dead) {
        out.push(<SpaceshipImage {...{x: (player.posn.x*1.5), y: player.posn.y * 3}}/>);
      }
    })
    return out
  }

  render() {
    const { players, aliens, barriers, lasers, alien_lasers, over} = this.state;
    const alienComponents = this.renderAliens(aliens);
    const playerComponents = this.renderPlayers(players);
    const barrierComponents = this.renderBarriers(barriers);
    const laserComponents = this.renderPlayerLasers(lasers);
    const alienLaserComponents = this.renderAlienLasers(alien_lasers);
    return <div tabIndex="0">
      <Stage width={925} height={800}>
        <Layer>
          {!over && playerComponents}
          {!over && alienComponents}
          {!over && barrierComponents}
          {!over && laserComponents}
          {!over && alienLaserComponents}
          {over && this.renderEndText()}
        </Layer>
      </Stage>
    </div>
  }

}

