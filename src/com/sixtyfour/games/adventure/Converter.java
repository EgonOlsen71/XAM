package com.sixtyfour.games.adventure;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Locale;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
 * @author EgonOlsen
 *
 */
public class Converter {

	public static void main(String[] args) {
		convertItems();
		convertCommands();
		convertRooms();
	}

	private static void convertCommands() {
		System.out.println("Converting commands");
		try (InputStream is = new FileInputStream("xml/commands/commands.xml");
				OutputStream os = new FileOutputStream(new File("seq/commands.def"))) {
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(is);
			NodeList its = doc.getElementsByTagName("command");
			for (int i = 0; i < its.getLength(); i++) {
				Element it = (Element) its.item(i);
				String cmd = it.getTextContent().trim();
				String id = it.getAttribute("id");
				String verb = it.getAttribute("verb");
				String[] parts = cmd.split(",");
				write(os, null, id + "|", false);
				write(os, null, parts.length + "|", false);
				write(os, null, verb + "|", false);
				for (String part : parts) {
					part = part.trim().toLowerCase(Locale.ENGLISH);
					write(os, null, part + "|", false);
				}
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		System.out.println("Done  with commands");
	}

	private static void convertItems() {
		System.out.println("Converting items");
		try (InputStream is = new FileInputStream("xml/items/items.xml");
				OutputStream os = new FileOutputStream(new File("seq/items.def"))) {
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(is);
			NodeList its = doc.getElementsByTagName("item");
			for (int i = 0; i < its.getLength(); i++) {
				Element it = (Element) its.item(i);
				Element it2 = (Element) it.getElementsByTagName("name").item(0);
				Element it3 = (Element) it.getElementsByTagName("desc").item(0);
				String name = it2.getTextContent().trim();
				String desc = it3.getTextContent().trim();
				String id = it.getAttribute("id");
				String inv = it.getAttribute("inventory");
				write(os, id + ";" + inv + ";", name + "|", false);
				write(os, null, desc + "|", true);
				write(os, null, "***|", false);
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}

		try (InputStream is = new FileInputStream("xml/items/items.xml");
				OutputStream os = new FileOutputStream(new File("seq/operations.def"))) {
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(is);
			NodeList its = doc.getElementsByTagName("operation");
			for (int i = 0; i < its.getLength(); i++) {
				convert(os, its, i);
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}

		System.out.println("Done  with items");

	}

	public static void convertRooms() {
		File[] rooms = new File("xml/rooms").listFiles(new FilenameFilter() {
			@Override
			public boolean accept(File dir, String name) {
				return name.endsWith(".xml");
			}
		});

		for (File room : rooms) {
			System.out.println("Converting " + room);
			String name = room.getName().replace(".xml", "");
			try (InputStream is = new FileInputStream(room);
					OutputStream os = new FileOutputStream(new File("seq/" + name + ".rom"))) {
				DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
				DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
				Document doc = dBuilder.parse(is);
				String roomId = doc.getDocumentElement().getAttribute("id");
				write(os, null, roomId + "|", false);
				Element dsce = (Element) doc.getElementsByTagName("desc").item(0);
				String desc = dsce.getTextContent().trim();
				write(os, null, desc + "|", true);
				write(os, null, "***|", false);

				// Exits
				NodeList its = doc.getElementsByTagName("exit");
				for (int i = 0; i < its.getLength(); i++) {
					Element it = (Element) its.item(i);
					desc = it.getTextContent().trim();
					String xRoom = it.getAttribute("room");
					String locked = it.getAttribute("locked");
					write(os, xRoom + ";" + (locked.isEmpty() ? "0" : locked) + ";", desc + "|", false);
				}
				write(os, null, "***|", false);

				// Items
				its = doc.getElementsByTagName("item");
				for (int i = 0; i < its.getLength(); i++) {
					Element it = (Element) its.item(i);
					desc = it.getTextContent().trim();
					write(os, null, desc + "|", false);
				}
				write(os, null, "***|", false);

				// Operations
				its = doc.getElementsByTagName("operation");
				for (int i = 0; i < its.getLength(); i++) {
					convert(os, its, i);
				}
				if (its.getLength() == 0) {
					write(os, null, "***|", false);
				}

			} catch (Exception e) {
				throw new RuntimeException(e);
			}
			System.out.println("Done  with " + room);
		}
		System.out.println("All done!");
	}

	private static String translate(String tmp) {
		String[] dirs = new String[] { "n", "s", "w", "o", "nw", "sw", "no", "so", "h", "r" };
		tmp = tmp.toLowerCase().trim();
		for (int i = 0; i < dirs.length; i++) {
			if (tmp.equals(dirs[i])) {
				return String.valueOf(i);
			}
		}
		return "-1";
	}

	private static void write(OutputStream os, String prefix, String txt, boolean fullText) {
		try {
			os.write(toBytes(prefix));
			txt = clean(txt);
			int ol = 0;
			do {
				ol = txt.length();
				txt = txt.replace("  ", " ");
			} while (txt.length() != ol);
			String[] parts = txt.split(" |\r");
			int len = 0;
			int pc = 0;
			for (String part : parts) {
				pc++;
				if (part.isEmpty()) {
					continue;
				}
				part = part.trim();
				boolean breaky = false;
				if (part.endsWith("~")) {
					part = part.substring(0, part.length() - 1);
					breaky = true;
				}
				len = len + part.length() + 1;
				if (pc < parts.length && parts[pc].length() + len > 40) {
					os.write(toBytes(part));
					os.write(toBytes("\r"));
					len = 0;
				} else {
					os.write(toBytes(part + (fullText ? " " : "")));
					if (breaky) {
						os.write(toBytes("\r"));
						len = 0;
					}
				}
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private static String clean(String txt) {
		txt = txt.replace("ö", "oe").replace("Ö", "Oe");
		txt = txt.replace("ä", "ae").replace("Ä", "Ae");
		txt = txt.replace("ü", "ue").replace("Ü", "Ue");
		txt = txt.replace("ß", "ss");
		txt = txt.replace("|", "~\r").replace("\t", " ");
		txt = txt.replace(",", ";");
		return txt;
	}

	private static byte[] toBytes(String txt) {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		if (txt != null) {
			for (int i = 0; i < txt.length(); i++) {
				char c = txt.charAt(i);
				int ci = getConvertedChar(c);
				bos.write(ci);
			}
		}
		return bos.toByteArray();
	}

	private static int getConvertedChar(int c) {
		if (c >= 'a' && c <= 'z') {
			c = (char) ((int) c - 32);
		} else if (c >= 'A' && c <= 'Z') {
			c = (char) ((int) c + 32);
		}
		return c;
	}

	private static void convert(OutputStream os, NodeList its, int i) {
		Element it = (Element) its.item(i);
		String tmp = it.getAttribute("command");
		write(os, null, tmp + "|", false);
		tmp = it.getAttribute("item");
		write(os, null, tmp + "|", false);
		tmp = it.getAttribute("unique");
		write(os, null, getZeroValue(tmp), false);
		tmp = it.getAttribute("remove_inv");
		write(os, null, getValue(tmp), false);
		tmp = it.getAttribute("remove_room");
		write(os, null, getValue(tmp), false);
		tmp = it.getAttribute("add_room");
		write(os, null, getValue(tmp), false);
		tmp = it.getAttribute("add_inv");
		write(os, null, getValue(tmp), false);
		tmp = it.getAttribute("unlock");
		write(os, null, ((tmp != null && !tmp.isEmpty()) ? translate(tmp) : "?") + "|", false);
		tmp = it.getAttribute("with_item");
		write(os, null, getValue(tmp), false);
		tmp = it.getAttribute("remove_both");
		write(os, null, getZeroValue(tmp), false);
		write(os, null, "?" + "|", false);
		String desc = it.getTextContent().trim();
		write(os, null, desc + "|", true);
		write(os, null, "***|", false);
	}

	private static String getZeroValue(String tmp) {
		return ((tmp != null && !tmp.isEmpty()) ? tmp : "0") + "|";
	}

	private static String getValue(String tmp) {
		return ((tmp != null && !tmp.isEmpty()) ? tmp : "-1") + "|";
	}

}
