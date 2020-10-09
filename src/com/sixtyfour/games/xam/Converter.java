package com.sixtyfour.games.xam;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

/**
 * A hacky converter tool that takes XML-files located in the xml-subdir and
 * converts it into SQE-files in the seq directory that the BASIC/compiled XAM
 * interpreter running on the C64 can then read.
 * 
 * @author EgonOlsen
 *
 */
public class Converter {

	private final static String[] DIRS = new String[] { "n", "s", "w", "o", "nw", "sw", "no", "so", "h", "r" };

	private int uniques = 0;
	private int itemOps = 0;
	private int maxOps = 0;
	private String maxOpsName = null;

	public static void main(String[] args) {
		Converter conv = new Converter();
		conv.convert();
	}

	public void convert() {
		uniques = 0;
		maxOps = 0;
		itemOps = 0;
		convertItems();
		convertCommands();
		int endId = convertRooms();
		writeEndId(endId);
		System.out.println("Unique operations in total: " + uniques);
		System.out.println("Number of item ops: " + itemOps);
		System.out.println("Maximum number of room ops: " + maxOps + "/" + maxOpsName);
	}

	private void writeEndId(int endId) {
		try (OutputStream os = new FileOutputStream(new File("seq/endid.def"))) {
			os.write(String.valueOf(endId).getBytes());
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private Reader getReader(String file) {
		try {
			return new InputStreamReader(new FileInputStream(file), "UTF-8");
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private Reader getReader(File file) {
		try {
			return new InputStreamReader(new FileInputStream(file), "UTF-8");
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private InputSource getInputSource(Reader fr) {
		InputSource is = new InputSource(fr);
		is.setEncoding("UTF-8");
		return is;
	}

	private void convertCommands() {
		System.out.println("Converting commands");
		try (Reader fr = getReader("xml/commands/commands.xml");
				OutputStream os = new FileOutputStream(new File("seq/commands.def"))) {
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(getInputSource(fr));
			NodeList its = doc.getElementsByTagName("command");
			for (int i = 0; i < its.getLength(); i++) {
				Element it = (Element) its.item(i);
				String cmd = getText(it);
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

	private void convertItems() {
		System.out.println("Converting items");
		try (Reader fr = getReader("xml/items/items.xml");
				OutputStream os = new FileOutputStream(new File("seq/items.def"))) {
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(getInputSource(fr));
			NodeList its = doc.getElementsByTagName("item");
			for (int i = 0; i < its.getLength(); i++) {
				Element it = (Element) its.item(i);
				Element it2 = (Element) it.getElementsByTagName("name").item(0);
				Element it3 = (Element) it.getElementsByTagName("desc").item(0);
				String name = getText(it2);
				String desc = getText(it3);
				String id = it.getAttribute("id");
				String inv = it.getAttribute("inventory");
				write(os, id + ";" + inv + ";", name + "|", false);
				write(os, null, desc + "|", true);
				write(os, null, "***|", false);
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}

		try (Reader fr = getReader("xml/items/items.xml");
				OutputStream os = new FileOutputStream(new File("seq/operations.def"))) {
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(getInputSource(fr));
			NodeList its = doc.getElementsByTagName("operation");
			itemOps = its.getLength();
			for (int i = 0; i < itemOps; i++) {
				convert(os, its, i);
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}

		System.out.println("Done  with items");

	}

	public int convertRooms() {
		File[] rooms = new File("xml/rooms").listFiles(new FilenameFilter() {
			@Override
			public boolean accept(File dir, String name) {
				return name.endsWith(".xml");
			}
		});

		Set<String> ids = new HashSet<>();
		int endId = 0;

		for (File room : rooms) {
			System.out.println("Converting " + room);
			String name = room.getName().replace(".xml", "");
			try (Reader fr = getReader(room);
					OutputStream os = new FileOutputStream(new File("seq/" + name + ".rom"))) {
				DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
				DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
				Document doc = dBuilder.parse(getInputSource(fr));
				String roomId = doc.getDocumentElement().getAttribute("id");
				String end = doc.getDocumentElement().getAttribute("end");
				if (Boolean.valueOf(end)) {
					endId = Integer.parseInt(roomId);
				}
				if (ids.contains(roomId)) {
					throw new RuntimeException("ID " + roomId + " isn't unique!");
				}
				ids.add(roomId);
				write(os, null, roomId + "|", false);
				Element dsce = (Element) doc.getElementsByTagName("desc").item(0);
				String desc = getText(dsce);
				write(os, null, desc + "|", true);
				write(os, null, "***|", false);

				// Exits
				NodeList its = doc.getElementsByTagName("exit");
				for (int i = 0; i < its.getLength(); i++) {
					Element it = (Element) its.item(i);
					desc = getText(it);
					String xRoom = it.getAttribute("room");
					String locked = it.getAttribute("locked");
					write(os, xRoom + ";" + (locked.isEmpty() ? "0" : locked) + ";", desc + "|", false);
				}
				write(os, null, "***|", false);

				// Items
				its = doc.getElementsByTagName("item");
				for (int i = 0; i < its.getLength(); i++) {
					Element it = (Element) its.item(i);
					desc = getText(it);
					write(os, null, desc + "|", false);
				}
				write(os, null, "***|", false);

				// Operations
				its = doc.getElementsByTagName("operation");
				int len = its.getLength();
				if (len > maxOps) {
					maxOps = len;
					maxOpsName = room.getName();
				}
				for (int i = 0; i < len; i++) {
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
		return endId;
	}

	private String translate(String tmp) {
		tmp = tmp.toLowerCase().trim();
		for (int i = 0; i < DIRS.length; i++) {
			if (tmp.equals(DIRS[i])) {
				return String.valueOf(i);
			}
		}
		return "-1";
	}

	private void write(OutputStream os, String prefix, String txt, boolean fullText) {
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

	private String clean(String txt) {
		txt = txt.replace("ö", "oe").replace("Ö", "Oe");
		txt = txt.replace("ä", "ae").replace("Ä", "Ae");
		txt = txt.replace("ü", "ue").replace("Ü", "Ue");
		txt = txt.replace("ß", "ss");
		txt = txt.replace("|", "~\r").replace("\t", " ");
		txt = txt.replace(",", ";");
		return txt;
	}

	private byte[] toBytes(String txt) {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		if (txt != null) {
			for (int i = 0; i < txt.length(); i++) {
				char c = txt.charAt(i);
				if (c == '_') {
					c = ' ';
				}
				int ci = getConvertedChar(c);
				bos.write(ci);
			}
		}
		return bos.toByteArray();
	}

	private int getConvertedChar(int c) {
		if (c >= 'a' && c <= 'z') {
			c = (char) ((int) c - 32);
		} else if (c >= 'A' && c <= 'Z') {
			c = (char) ((int) c + 32);
		}
		return c;
	}

	private void convert(OutputStream os, NodeList its, int i) {
		Element it = (Element) its.item(i);
		String tmp = it.getAttribute("command");
		write(os, null, tmp + "|", false);
		tmp = it.getAttribute("item");
		write(os, null, tmp + "|", false);
		tmp = it.getAttribute("unique");
		String v = getZeroValue(tmp);
		if (!v.startsWith("0")) {
			uniques++;
		}
		write(os, null, v, false);
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
		tmp = it.getAttribute("portal_to");
		write(os, null, getValue(tmp), false);
		String desc = getText(it);
		write(os, null, desc + "|", true);
		write(os, null, "***|", false);
	}

	private String getText(Element it) {
		String tmp = it.getTextContent().trim();
		tmp = tmp.replace("\"", "'").replace(":", ".");
		return tmp;
	}

	private String getZeroValue(String tmp) {
		return ((tmp != null && !tmp.isEmpty()) ? tmp : "0") + "|";
	}

	private String getValue(String tmp) {
		return ((tmp != null && !tmp.isEmpty()) ? tmp : "-1") + "|";
	}

}
